#!/usr/bin/env python3
"""Consumer-project smoke test for the eagle_eye checkout.

Runs the CLI from this checkout against a real Dart/Flutter consumer project,
exercising every rule type and CLI path with temporary configs kept outside the
consumer, then validates the captured runs against an independent oracle.

Typical use (from the eagle-eye repo root):

    ART=$(mktemp -d)
    python3 .opencode/skills/consumer-app-test/scripts/consumer_check.py \
        prepare --target ../todoapp_flutter --art "$ART"
    python3 .opencode/skills/consumer-app-test/scripts/consumer_check.py \
        run --art "$ART"
    python3 .opencode/skills/consumer-app-test/scripts/consumer_check.py \
        verify --art "$ART"

The consumer project is only ever read; every generated config, scratch project
and captured run lives under --art. Python 3.8+, standard library only.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import time
from collections import Counter
from pathlib import Path
from urllib.parse import unquote, urlparse

DEFAULT_REPO = Path(__file__).resolve().parents[4]

ANSI_RE = re.compile(r'\x1b\[[0-9;]*m')
HEADER_RE = re.compile(r'^lib/.*\.dart$')
RULE_RE = re.compile(
    r'^  \u2717 (no-imports-allowed|forbidden-dependency|exclusive-dependency)'
    r'(?:: "(.*)")?$'
)
IMPORT_RE = re.compile(r'^    \u2022 (\d+): import \'(.*)\';$')
SUMMARY_RE = re.compile(
    r'^\u2717 Verification failed: (\d+) errors in (\d+) files \U0001F985$'
)
SUCCESS_LINE = '\U0001F985 Verification finished'
VERBOSE_PREFIX = '\U0001F985 [verbose]'
ERROR_PREFIX = '\U0001F985 '
USAGE_NEEDLES = (
    'Usage: dart run eagle_eye:main',
    '--verbose',
    '--config',
    '--help',
)

IMPORT_SCAN_RE = re.compile(r"""^import\s+(?:'([^']*)'|"([^"]*)")""")

CRASH_PATTERNS = (
    re.compile(r'Unhandled exception'),
    re.compile(r'^#\d+\s', re.MULTILINE),
    re.compile(r'PathAccessException'),
    re.compile(r'update_engine_version\.sh'),
    re.compile(r'Operation not permitted'),
    re.compile(r'dartdev'),
)

NEVER = '__eagle_eye_consumer_test_never__'


# ---------------------------------------------------------------------------
# Small helpers
# ---------------------------------------------------------------------------


def fail(message: str) -> None:
    print(f'ERROR: {message}', file=sys.stderr)
    raise SystemExit(1)


def strip_ansi(text: str) -> str:
    return ANSI_RE.sub('', text)


def read_text(path: Path) -> str:
    return path.read_text(encoding='utf-8', errors='replace')


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')


def read_json(path: Path):
    return json.loads(read_text(path))


def write_json(path: Path, data) -> None:
    write_text(path, json.dumps(data, indent=2, ensure_ascii=False) + '\n')


def first_lines(text: str, count: int) -> str:
    lines = [line for line in strip_ansi(text).splitlines() if line.strip()]
    return ' | '.join(lines[:count])


def run_process(cmd, cwd: Path, timeout: int = 300):
    """Run a command and return (exit_code, stdout, stderr)."""
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace',
            timeout=timeout,
        )
        return proc.returncode, proc.stdout, proc.stderr
    except subprocess.TimeoutExpired as exc:
        out = exc.stdout or ''
        err = (exc.stderr or '') + '\n[consumer_check: timed out]'
        return 124, out, err
    except OSError as exc:
        return 127, '', f'[consumer_check: failed to execute {cmd!r}: {exc}]'


def run_git(path: Path, args):
    try:
        proc = subprocess.run(
            ['git', '-C', str(path), *args],
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace',
            timeout=60,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout


def snapshot(path: Path) -> dict:
    head = run_git(path, ['rev-parse', '--short', 'HEAD'])
    dirty = run_git(path, ['status', '--porcelain'])
    if head is None:
        return {'path': str(path), 'head': None, 'dirty': None}
    return {
        'path': str(path),
        'head': head.strip(),
        'dirty': sorted(dirty.splitlines()) if dirty is not None else None,
    }


def parse_pubspec_name(path: Path):
    if not path.is_file():
        return None
    for line in read_text(path).splitlines():
        match = re.match(r'^name:\s*(\S+)', line)
        if match:
            value = match.group(1).strip('\'"')
            return value if value else None
    return None


def root_uri_to_path(root_uri: str, config_dir: Path) -> Path:
    if root_uri.startswith('file:'):
        return Path(unquote(urlparse(root_uri).path)).resolve()
    return (config_dir / root_uri).resolve()


def resolve_package_dir(config_path: Path, name: str):
    try:
        config = read_json(config_path)
    except (OSError, ValueError) as exc:
        fail(f'cannot read package config {config_path}: {exc}')
    config_dir = config_path.parent
    for package in config.get('packages', []):
        if package.get('name') == name:
            root_uri = package.get('rootUri')
            if not isinstance(root_uri, str):
                return None
            return root_uri_to_path(root_uri, config_dir)
    return None


def is_real_binary(path: Path) -> bool:
    try:
        head = path.read_bytes()[:4]
    except OSError:
        return False
    sign = head[:2]
    if sign in (b'#!', b'@e'):  # shell script / Windows batch wrapper
        return False
    magics = (
        b'\x7fELF',
        b'\xfe\xed\xfa\xce',
        b'\xce\xfa\xed\xfe',
        b'\xfe\xed\xfa\xcf',
        b'\xcf\xfa\xed\xfe',
        b'\xca\xfe\xba\xbe',
    )
    return head in magics


def dart_version(binary: Path):
    code, out, err = run_process([str(binary), '--version'], cwd=binary.parent, timeout=30)
    match = re.search(r'Dart SDK version:\s*(\d+)\.(\d+)\.(\d+)', out + err)
    if code != 0 or match is None:
        return None
    version = tuple(int(part) for part in match.groups())
    return f'{match.group(0).split(":")[1].strip()}', version


def version_key(text: str):
    match = re.search(r'(\d+)\.(\d+)\.(\d+)', text)
    if match is None:
        return (0, 0, 0)
    return tuple(int(part) for part in match.groups())


def resolve_dart(explicit):
    candidates = []
    if explicit:
        candidates.append(('--dart', Path(explicit).expanduser()))
    env = os.environ.get('DART_BIN')
    if env:
        candidates.append(('DART_BIN', Path(env).expanduser()))
    which = shutil.which('dart')
    if which:
        candidates.append(('PATH', Path(which)))

    patterns = (
        ('asdf dart', Path.home() / '.asdf' / 'installs' / 'dart' / '*' / 'bin' / 'dart'),
        (
            'asdf flutter SDK',
            Path.home()
            / '.asdf'
            / 'installs'
            / 'flutter'
            / '*'
            / 'bin'
            / 'cache'
            / 'dart-sdk'
            / 'bin'
            / 'dart',
        ),
    )
    for label, pattern in patterns:
        for found in sorted(glob.glob(str(pattern)), key=version_key, reverse=True):
            candidates.append((label, Path(found)))

    rejected = []
    seen = set()
    for label, path in candidates:
        if not path.exists():
            continue
        resolved = path.resolve()
        if resolved in seen:
            continue
        seen.add(resolved)
        if not is_real_binary(resolved):
            rejected.append(f'{label}: {resolved} is a wrapper/shim, skipped')
            continue
        version = dart_version(resolved)
        if version is None:
            rejected.append(f'{label}: {resolved} did not answer --version')
            continue
        version_text, version_tuple = version
        if version_tuple < (3, 8, 0):
            rejected.append(
                f'{label}: {resolved} is Dart {version_text}, '
                'eagle_eye needs Dart 3.8+'
            )
            continue
        return {'path': str(resolved), 'version': version_text}, rejected
    fail(
        'no usable Dart SDK found. Pass --dart /path/to/dart or set DART_BIN. '
        'Details: ' + ('; '.join(rejected) if rejected else 'no candidates')
    )


# ---------------------------------------------------------------------------
# Oracle: independent count of internal imports in the consumer
# ---------------------------------------------------------------------------


def scan_internal_imports(target: Path, app_name: str):
    """Return one record per internal import line in the consumer's lib/."""
    records = []
    for path in sorted((target / 'lib').rglob('*.dart')):
        if not path.is_file():
            continue
        relative = path.relative_to(target).as_posix()
        in_block = False
        for line_number, line in enumerate(read_text(path).splitlines(), 1):
            if in_block:
                if '*/' in line:
                    in_block = False
                continue
            if line.lstrip().startswith('/*') and '*/' not in line:
                in_block = True
                continue
            match = IMPORT_SCAN_RE.match(line)
            if match is None:
                continue
            uri = match.group(1) if match.group(1) is not None else match.group(2)
            if app_name not in uri:
                continue
            records.append(
                {'file': relative, 'line': line_number, 'uri': uri}
            )
    return records


def package_import_pattern(app_name: str) -> re.Pattern:
    return re.compile(r'package:' + re.escape(app_name) + r'/')


# ---------------------------------------------------------------------------
# prepare
# ---------------------------------------------------------------------------


def cmd_prepare(args) -> int:
    repo = Path(args.repo).expanduser().resolve() if args.repo else DEFAULT_REPO
    target = Path(args.target).expanduser().resolve()
    art = Path(args.art).expanduser().resolve()

    if not target.is_dir():
        fail(f'target project directory not found: {target}')
    if not (target / 'pubspec.yaml').is_file():
        fail(f'target has no pubspec.yaml: {target}')
    app_name = parse_pubspec_name(target / 'pubspec.yaml')
    if not app_name:
        fail(f'target pubspec.yaml has no "name:" field: {target}')
    lib_dir = target / 'lib'
    if not lib_dir.is_dir():
        fail(f'target has no lib/ directory: {target}')
    if not any(lib_dir.rglob('*.dart')):
        fail(f'target lib/ contains no Dart files: {target}')

    if parse_pubspec_name(repo / 'pubspec.yaml') != 'eagle_eye':
        fail(f'--repo does not look like the eagle_eye checkout: {repo}')
    package_config = repo / '.dart_tool' / 'package_config.json'
    if not package_config.is_file():
        fail(
            f'{package_config} is missing. Run `dart pub get` in {repo} '
            'first (never in the consumer).'
        )
    resolved_repo = resolve_package_dir(package_config, 'eagle_eye')
    if resolved_repo != repo:
        fail(
            'the package config does not resolve eagle_eye to this checkout: '
            f'{resolved_repo} != {repo}'
        )

    dart, rejected_dart = resolve_dart(args.dart)

    target_snapshot = snapshot(target)
    repo_snapshot = snapshot(repo)
    target_config = target / 'eagle_eye_config.json'

    art.mkdir(parents=True, exist_ok=True)
    configs = art / 'configs'
    configs.mkdir(parents=True, exist_ok=True)
    scratch = art / 'scratch'
    no_lib = scratch / 'no-lib'
    no_pubspec = scratch / 'no-pubspec'
    no_lib.mkdir(parents=True, exist_ok=True)
    write_text(no_pubspec / 'lib' / 'plain.dart', '// No imports here.\n')
    absent_config = art / 'configs' / 'absent-config.json'
    if absent_config.exists():
        absent_config.unlink()

    positive_config = configs / 'positive.json'
    forbidden_config = configs / 'forbidden.json'
    no_imports_config = configs / 'no-imports.json'
    pass_config = configs / 'pass.json'
    conflict_config = configs / 'conflict.json'
    deprecated_config = configs / 'deprecated.json'
    backslash_config = configs / 'backslash.json'
    valid_config = configs / 'valid.json'

    write_json(positive_config, [
        {
            'filePattern': 'lib/*',
            'exclusiveDependencies': [NEVER],
            'name': 'consumer-test-exclusive',
        },
    ])
    write_json(forbidden_config, [
        {
            'filePattern': 'lib/*',
            'forbiddenDependencies': [f'package:{app_name}/*'],
            'name': 'consumer-test-forbidden',
        },
    ])
    write_json(no_imports_config, [
        {
            'filePattern': 'lib/*',
            'dependenciesAllowed': False,
            'name': 'consumer-test-no-imports',
        },
    ])
    write_json(pass_config, [
        {
            'filePattern': 'lib/*',
            'forbiddenDependencies': [NEVER],
            'name': 'consumer-test-pass',
        },
    ])
    write_json(conflict_config, [
        {'filePattern': 'lib/*', 'name': 'conflict-a', 'dependenciesAllowed': False},
        {'filePattern': 'lib/*', 'name': 'conflict-b', 'dependenciesAllowed': False},
    ])
    write_json(deprecated_config, [
        {'filePattern': 'lib/*', 'doNotWithPatterns': ['x']},
    ])
    write_json(backslash_config, [
        {'filePattern': 'lib\\main.dart', 'name': 'consumer-test-backslash'},
    ])
    write_json(valid_config, [
        {'filePattern': 'lib/*', 'forbiddenDependencies': [NEVER]},
    ])

    records = scan_internal_imports(target, app_name)
    if not records:
        fail(
            'the consumer has no internal imports (no import URI contains '
            f'"{app_name}"), so the rules cannot be exercised.'
        )
    oracle_files = sorted({record['file'] for record in records})
    package_re = package_import_pattern(app_name)
    package_records = [record for record in records if package_re.search(record['uri'])]
    package_files = sorted({record['file'] for record in package_records})
    non_package = [record for record in records if package_re.search(record['uri']) is None]
    non_package_files = sorted({record['file'] for record in non_package})

    hero = None
    if args.file:
        hero = normalize_hero(args.file, target)
        if hero is None:
            fail(f'--file is not inside the target project: {args.file}')
        if hero not in oracle_files:
            fail(
                f'--file {hero} has no internal imports; pick a file that '
                f'imports package:{app_name}/...'
            )
    else:
        hero = oracle_files[0]
    hero_imports = [record for record in records if record['file'] == hero]

    baseline = {'available': False, 'reason': 'consumer has no .dart_tool/package_config.json'}
    target_package_config = target / '.dart_tool' / 'package_config.json'
    if target_package_config.is_file():
        baseline_root = resolve_package_dir(target_package_config, 'eagle_eye')
        if baseline_root is None:
            baseline = {
                'available': False,
                'reason': 'the consumer does not depend on eagle_eye',
            }
        elif not (baseline_root / 'bin' / 'main.dart').is_file():
            baseline = {
                'available': False,
                'reason': f'resolved eagle_eye has no bin/main.dart: {baseline_root}',
            }
        else:
            match = re.search(r'eagle_eye-(.+)$', baseline_root.name)
            baseline = {
                'available': True,
                'version': match.group(1) if match else 'unknown',
                'root': str(baseline_root),
                'packageConfig': str(target_package_config),
            }

    executors = {
        'local': {
            'dart': dart['path'],
            'packages': str(package_config),
            'main': str(repo / 'bin' / 'main.dart'),
        },
    }
    if baseline['available']:
        executors['baseline'] = {
            'dart': dart['path'],
            'packages': baseline['packageConfig'],
            'main': str(Path(baseline['root']) / 'bin' / 'main.dart'),
        }

    def violation_expect(count, file_set, types):
        return {
            'count': count,
            'files': len(file_set),
            'fileSet': file_set,
            'types': types,
        }

    runs = []
    if target_config.is_file():
        runs.append({
            'label': 'default',
            'source': 'local',
            'cwd': str(target),
            'argv': [],
            'kind': 'auto',
            'expect': {},
        })
    else:
        runs.append({
            'label': 'default',
            'source': 'local',
            'cwd': str(target),
            'argv': [],
            'kind': 'error',
            'expect': {'message': 'Unable to load configuration file'},
            'notes': 'consumer has no eagle_eye_config.json',
        })

    runs.extend([
        {
            'label': 'positive',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config)],
            'kind': 'violations',
            'expect': violation_expect(
                len(records), oracle_files, {'exclusive-dependency': len(records)}
            ),
        },
        {
            'label': 'forbidden',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(forbidden_config)],
            'kind': 'violations' if package_records else 'success',
            'expect': violation_expect(
                len(package_records),
                package_files,
                {'forbidden-dependency': len(package_records)},
            ) if package_records else {},
        },
        {
            'label': 'no-imports',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(no_imports_config)],
            'kind': 'violations',
            'expect': violation_expect(
                len(records), oracle_files, {'no-imports-allowed': len(records)}
            ),
        },
        {
            'label': 'pass',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(pass_config)],
            'kind': 'success',
            'expect': {},
        },
        {
            'label': 'verbose',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config), '--verbose'],
            'kind': 'violations',
            'expect': violation_expect(
                len(records), oracle_files, {'exclusive-dependency': len(records)}
            ),
            'compare': {'label': 'positive', 'mode': 'records'},
        },
        {
            'label': 'determinism',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config)],
            'kind': 'violations',
            'expect': violation_expect(
                len(records), oracle_files, {'exclusive-dependency': len(records)}
            ),
            'compare': {'label': 'positive', 'mode': 'identical'},
        },
        {
            'label': 'files-hit',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config), hero],
            'kind': 'violations',
            'expect': violation_expect(
                len(hero_imports), [hero], {'exclusive-dependency': len(hero_imports)}
            ),
            'compare': {'label': 'positive', 'mode': 'subset', 'file': hero},
        },
        {
            'label': 'files-abs',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config), str(target / hero)],
            'kind': 'violations',
            'expect': violation_expect(
                len(hero_imports), [hero], {'exclusive-dependency': len(hero_imports)}
            ),
            'compare': {'label': 'files-hit', 'mode': 'records'},
        },
        {
            'label': 'files-dup',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config), hero, hero],
            'kind': 'violations',
            'expect': violation_expect(
                len(hero_imports), [hero], {'exclusive-dependency': len(hero_imports)}
            ),
            'compare': {'label': 'files-hit', 'mode': 'records'},
        },
        {
            'label': 'files-missing',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config), 'lib/__eagle_eye_nope__.dart'],
            'kind': 'error',
            'expect': {'message': 'does not exist'},
        },
        {
            'label': 'files-outside',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(positive_config), 'pubspec.yaml'],
            'kind': 'error',
            'expect': {'message': 'is not a Dart (.dart) file'},
        },
        {
            'label': 'conflict',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(conflict_config)],
            'kind': 'error',
            'expect': {'message': 'match exactly one rule'},
        },
        {
            'label': 'deprecated-key',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(deprecated_config)],
            'kind': 'error',
            'expect': {'message': 'Invalid keys found'},
        },
        {
            'label': 'backslash-pattern',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(backslash_config)],
            'kind': 'error',
            'expect': {'message': 'uses a backslash'},
        },
        {
            'label': 'missing-config',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--config', str(absent_config)],
            'kind': 'error',
            'expect': {'message': 'Unable to load configuration file'},
        },
        {
            'label': 'help',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--help'],
            'kind': 'help',
            'expect': {},
        },
        {
            'label': 'unknown-flag',
            'source': 'local',
            'cwd': str(target),
            'argv': ['--nope'],
            'kind': 'error',
            'expect': {'message': 'Could not find an option'},
        },
        {
            'label': 'no-lib',
            'source': 'local',
            'cwd': str(no_lib),
            'argv': ['--config', str(valid_config)],
            'kind': 'error',
            'expect': {'message': 'libs folder was not found'},
        },
        {
            'label': 'no-pubspec',
            'source': 'local',
            'cwd': str(no_pubspec),
            'argv': ['--config', str(valid_config)],
            'kind': 'diagnostic',
            'expect': {'message': 'Unable to detect the name of you app'},
            'notes': 'malformed consumer probe: a friendly error is expected, '
                     'an unhandled exception is reported as a diagnostic',
        },
    ])
    if baseline['available']:
        runs.append({
            'label': 'baseline-default',
            'source': 'baseline',
            'cwd': str(target),
            'argv': [],
            'kind': 'auto',
            'expect': {},
            'compare': {'label': 'default', 'mode': 'drift'},
        })

    manifest = {
        'schema': 1,
        'createdAt': time.strftime('%Y-%m-%dT%H:%M:%S%z'),
        'repo': repo_snapshot,
        'target': target_snapshot,
        'appName': app_name,
        'targetConfig': str(target_config) if target_config.is_file() else None,
        'dart': dart,
        'dartRejected': rejected_dart,
        'packageConfig': str(package_config),
        'localResolvedRoot': str(resolved_repo),
        'heroFile': hero,
        'heroImports': len(hero_imports),
        'oracle': {
            'internalImports': len(records),
            'files': len(oracle_files),
            'fileSet': oracle_files,
            'nonPackageImports': len(non_package),
            'nonPackageFiles': non_package_files,
        },
        'baseline': baseline,
        'executors': executors,
        'runs': runs,
    }
    manifest_path = art / 'manifest.json'
    write_json(manifest_path, manifest)

    print(f'target        : {target} ({app_name})')
    print(f'repo          : {repo}')
    print(f'package config: {package_config} -> eagle_eye at {resolved_repo}')
    print(f'dart          : {dart["path"]} ({dart["version"]})')
    if rejected_dart:
        print('dart notes    : ' + '; '.join(rejected_dart))
    if baseline['available']:
        print(f'baseline      : eagle_eye {baseline["version"]} at {baseline["root"]}')
    else:
        print(f'baseline      : unavailable ({baseline["reason"]})')
    print(
        f'oracle        : {len(records)} internal imports in '
        f'{len(oracle_files)} files ({len(non_package)} non-package)'
    )
    print(f'hero file     : {hero} ({len(hero_imports)} internal imports)')
    print(f'artifacts     : {art}')
    print(f'manifest      : {manifest_path}')
    print(f'next          : {Path(__file__).as_posix()} run --art {art}')
    return 0


def normalize_hero(raw: str, target: Path):
    text = raw.replace('\\', '/')
    path = Path(text)
    if path.is_absolute():
        try:
            relative = path.resolve().relative_to(target)
        except ValueError:
            return None
    else:
        relative = path
    parts = [part for part in relative.as_posix().split('/') if part not in ('', '.')]
    if '..' in parts:
        return None
    canonical = '/'.join(parts)
    if not canonical.startswith('lib/'):
        canonical = 'lib/' + canonical
    return canonical


# ---------------------------------------------------------------------------
# run
# ---------------------------------------------------------------------------


def cmd_run(args) -> int:
    art = Path(args.art).expanduser().resolve()
    manifest_path = art / 'manifest.json'
    if not manifest_path.is_file():
        fail(f'no manifest at {manifest_path}; run `prepare` first')
    manifest = read_json(manifest_path)
    executors = manifest['executors']
    if args.dart:
        for executor in executors.values():
            executor['dart'] = str(Path(args.dart).expanduser().resolve())

    failures = 0
    for run in manifest['runs']:
        label = run['label']
        source = run['source']
        executor = executors.get(source)
        if executor is None:
            print(f'SKIP {label}: no {source} executor in the manifest')
            failures += 1
            continue
        command = [
            executor['dart'],
            f'--packages={executor["packages"]}',
            executor['main'],
            *run['argv'],
        ]
        started = time.time()
        exit_code, stdout, stderr = run_process(command, Path(run['cwd']))
        elapsed = time.time() - started
        write_text(art / f'{label}.stdout', stdout)
        write_text(art / f'{label}.stderr', stderr)
        write_text(art / f'{label}.exit', f'{exit_code}\n')
        write_text(
            art / f'{label}.cmd',
            shlex.join(command) + f'\n# cwd: {run["cwd"]}\n',
        )
        print(
            f'{label:22} exit={exit_code:<3} {elapsed:5.2f}s  '
            f'{(first_lines(stdout, 1) or first_lines(stderr, 1) or "")[:110]}'
        )
    print(f'captures written under {art}')
    print(f'next: {Path(__file__).as_posix()} verify --art {art}')
    return 1 if failures else 0


# ---------------------------------------------------------------------------
# verify
# ---------------------------------------------------------------------------


def parse_output(stdout: str):
    stripped = strip_ansi(stdout)
    raw_lines = stripped.splitlines()
    verbose_lines = [line for line in raw_lines if line.startswith(VERBOSE_PREFIX)]
    lines = [line for line in raw_lines if not line.startswith(VERBOSE_PREFIX)]

    summary_line = None
    for line in lines:
        if SUMMARY_RE.match(line):
            summary_line = line
            break
    success_lines = [line for line in lines if line == SUCCESS_LINE]
    error_lines = [line for line in lines if line.startswith(ERROR_PREFIX)]

    parsed = {
        'text': stripped,
        'lines': [line for line in lines if line.strip()],
        'verboseLines': verbose_lines,
        'mode': 'unknown',
        'files': [],
        'records': [],
        'summary': None,
        'problems': [],
        'successLines': success_lines,
        'errorLines': error_lines,
    }

    if summary_line is not None:
        parsed['mode'] = 'violations'
        summary_index = lines.index(summary_line)
        body = lines[:summary_index]
        trailing = [line for line in lines[summary_index + 1:] if line.strip()]
        if trailing:
            parsed['problems'].append(
                'output after the summary line: ' + first_lines('\n'.join(trailing), 1)
            )
        files, records, structural = parse_violation_body(body)
        parsed['files'] = files
        parsed['records'] = records
        parsed['problems'].extend(structural)
        match = SUMMARY_RE.match(summary_line)
        parsed['summary'] = (int(match.group(1)), int(match.group(2)))
        if success_lines:
            parsed['problems'].append(
                'both a violation summary and the success message are present'
            )
    elif success_lines:
        parsed['mode'] = 'success'
    elif error_lines:
        parsed['mode'] = 'error'
    return parsed


def parse_violation_body(lines):
    files = []
    records = []
    problems = []
    state = 'start'
    current_rule = None
    for line in lines:
        if not line.strip():
            continue
        if HEADER_RE.match(line):
            if line in files:
                problems.append(f'file header repeated: {line}')
            files.append(line)
            state = 'header'
            current_rule = None
            continue
        match = RULE_RE.match(line)
        if match is not None:
            if state not in ('header', 'import'):
                problems.append(f'unexpected rule line: {line!r}')
            current_rule = (match.group(1), match.group(2))
            state = 'rule'
            continue
        match = IMPORT_RE.match(line)
        if match is not None:
            if state != 'rule' or current_rule is None or not files:
                problems.append(f'import line without a rule: {line!r}')
                continue
            records.append({
                'file': files[-1],
                'line': int(match.group(1)),
                'uri': match.group(2),
                'type': current_rule[0],
                'name': current_rule[1],
            })
            state = 'import'
            continue
        problems.append(f'unexpected line: {line!r}')
    return files, records, problems


def record_key(record):
    return (
        record['file'],
        record['line'],
        record['uri'],
        record['type'],
        record['name'] or '',
    )


def validate_violations(parsed, run, manifest, target, problems):
    files = parsed['files']
    records = parsed['records']
    file_set = set(files)
    if len(file_set) != len(files):
        problems.append('duplicate file groups in the output')
    if files != sorted(files):
        problems.append('file groups are not sorted alphabetically')
    for file_name in files:
        if not any(record['file'] == file_name for record in records):
            problems.append(f'file group without violations: {file_name}')

    if parsed['summary'] is not None:
        expected_errors, expected_files = parsed['summary']
        if expected_errors != len(records):
            problems.append(
                f'summary says {expected_errors} errors but {len(records)} '
                'violations were printed'
            )
        if expected_files != len(files):
            problems.append(
                f'summary says {expected_files} files but {len(files)} '
                'file groups were printed'
            )

    seen = set()
    sources = {}
    for record in records:
        key = (record['file'], record['line'], record['uri'])
        if key in seen:
            problems.append(f'duplicate violation: {key}')
        seen.add(key)

        if not record['file'].startswith('lib/'):
            problems.append(f'reported file is outside lib/: {record["file"]}')
            continue
        path = target / record['file']
        if not path.is_file():
            problems.append(f'reported file does not exist: {record["file"]}')
            continue
        if path not in sources:
            sources[path] = read_text(path).splitlines()
        source_lines = sources[path]
        if record['line'] < 1 or record['line'] > len(source_lines):
            problems.append(
                f'line {record["line"]} is outside {record["file"]} '
                f'({len(source_lines)} lines)'
            )
            continue
        source_line = source_lines[record['line'] - 1]
        if re.search(
            r'import\s+[\'"]' + re.escape(record['uri']) + r'[\'"]', source_line
        ) is None:
            problems.append(
                f'{record["file"]}:{record["line"]} does not import '
                f'{record["uri"]!r}'
            )
        if manifest['appName'] not in record['uri']:
            problems.append(
                f'reported an external import as internal: {record["uri"]!r}'
            )

    expectation = run.get('expect') or {}
    if 'count' in expectation and expectation['count'] != len(records):
        problems.append(
            f'expected {expectation["count"]} violations, found {len(records)}'
        )
    if 'files' in expectation and expectation['files'] != len(files):
        problems.append(
            f'expected {expectation["files"]} files with violations, '
            f'found {len(files)}'
        )
    if 'fileSet' in expectation:
        expected_files = sorted(expectation['fileSet'])
        if sorted(files) != expected_files:
            missing = sorted(set(expected_files) - file_set)
            extra = sorted(file_set - set(expected_files))
            problems.append(
                'file set differs from the oracle'
                + (f'; missing: {missing[:5]}' if missing else '')
                + (f'; unexpected: {extra[:5]}' if extra else '')
            )
    if 'types' in expectation:
        histogram = dict(Counter(record['type'] for record in records))
        if histogram != expectation['types']:
            problems.append(
                f'violation types differ: expected {expectation["types"]}, '
                f'found {histogram}'
            )


def check_run(run, manifest, target, stdout, stderr, exit_code):
    source = run['source']
    kind = run['kind']
    result = {
        'label': run['label'],
        'source': source,
        'kind': kind,
        'exit': exit_code,
        'mode': None,
        'count': 0,
        'files': 0,
        'records': [],
        'lines': [],
        'problems': [],
        'info': [],
        'compare': run.get('compare'),
    }
    problems = result['problems']

    combined = stdout + '\n' + stderr
    if kind != 'diagnostic':
        for pattern in CRASH_PATTERNS:
            match = pattern.search(combined)
            if match is not None:
                problems.append(
                    f'environment or crash marker {pattern.pattern!r}: '
                    f'{match.group(0)!r}'
                )
                break
        if source != 'baseline' and stderr.strip():
            problems.append('stderr is not empty: ' + first_lines(stderr, 3))

    parsed = parse_output(stdout)
    result['mode'] = parsed['mode']
    result['count'] = len(parsed['records'])
    result['files'] = len(parsed['files'])
    result['records'] = parsed['records']
    result['lines'] = parsed['lines']
    problems.extend(parsed['problems'])

    if kind == 'help':
        if exit_code != 0:
            problems.append(f'--help must exit 0, got {exit_code}')
        for needle in USAGE_NEEDLES:
            if needle not in parsed['text']:
                problems.append(f'--help output is missing {needle!r}')
        if parsed['mode'] != 'unknown':
            problems.append('--help printed an analysis result')
    elif kind == 'success':
        if exit_code != 0:
            problems.append(f'success run must exit 0, got {exit_code}')
        if parsed['mode'] != 'success':
            problems.append(
                f'expected the success message, detected {parsed["mode"]}'
            )
        if parsed['records'] or parsed['files']:
            problems.append('success output contains violation rows')
    elif kind == 'violations':
        if exit_code != 1:
            problems.append(f'violations must exit 1, got {exit_code}')
        if parsed['mode'] != 'violations':
            problems.append(
                f'expected a violation report, detected {parsed["mode"]}'
            )
        else:
            validate_violations(parsed, run, manifest, target, problems)
    elif kind == 'error':
        if exit_code != 1:
            problems.append(f'error run must exit 1, got {exit_code}')
        if parsed['mode'] != 'error':
            problems.append(f'expected an error message, detected {parsed["mode"]}')
        if parsed['records'] or parsed['files']:
            problems.append('error output contains violation rows')
        message = (run.get('expect') or {}).get('message')
        if message and message not in parsed['text']:
            problems.append(f'error message is missing {message!r}')
    elif kind == 'diagnostic':
        message = (run.get('expect') or {}).get('message')
        graceful = (
            exit_code == 1
            and parsed['mode'] == 'error'
            and (not message or message in parsed['text'])
        )
        if graceful:
            result['info'].append(
                'malformed consumer produced the expected friendly error'
            )
        else:
            problems.append(
                'malformed consumer was not handled gracefully: '
                f'exit={exit_code} mode={parsed["mode"]}; '
                f'output: {first_lines(stderr or stdout, 2) or "(empty)"}'
            )
    elif kind == 'auto':
        if parsed['mode'] == 'success':
            if exit_code != 0:
                problems.append(f'success must exit 0, got {exit_code}')
        elif parsed['mode'] == 'violations':
            if exit_code != 1:
                problems.append(f'violations must exit 1, got {exit_code}')
            validate_violations(parsed, run, manifest, target, problems)
        elif parsed['mode'] == 'error':
            if exit_code != 1:
                problems.append(f'error must exit 1, got {exit_code}')
        else:
            problems.append('output was neither success, violations nor an error')
    else:
        problems.append(f'unknown scenario kind: {kind}')

    if source == 'baseline' or kind == 'diagnostic':
        prefix = 'diagnostic: ' if kind == 'diagnostic' else 'baseline: '
        result['info'].extend(f'{prefix}{item}' for item in problems)
        result['problems'] = []

    return result


def cmd_verify(args) -> int:
    art = Path(args.art).expanduser().resolve()
    manifest_path = art / 'manifest.json'
    if not manifest_path.is_file():
        fail(f'no manifest at {manifest_path}; run `prepare` first')
    manifest = read_json(manifest_path)
    target = Path(manifest['target']['path'])
    runs = manifest['runs']
    only = set(args.only) if args.only else None

    results = {}
    for run in runs:
        label = run['label']
        if only is not None and label not in only:
            continue
        stdout_path = art / f'{label}.stdout'
        stderr_path = art / f'{label}.stderr'
        exit_path = art / f'{label}.exit'
        missing = [
            path.name
            for path in (stdout_path, stderr_path, exit_path)
            if not path.is_file()
        ]
        if missing:
            results[label] = {
                'label': label,
                'source': run['source'],
                'kind': run['kind'],
                'exit': None,
                'mode': None,
                'count': 0,
                'files': 0,
                'records': [],
                'lines': [],
                'problems': [f'missing capture(s): {", ".join(missing)}; run `run` first'],
                'info': [],
                'compare': run.get('compare'),
            }
            continue
        exit_text = read_text(exit_path).strip()
        try:
            exit_code = int(exit_text)
        except ValueError:
            exit_code = -1
        result = check_run(
            run,
            manifest,
            target,
            read_text(stdout_path),
            read_text(stderr_path),
            exit_code,
        )
        results[label] = result

    global_problems = []
    for run in runs:
        label = run['label']
        if label not in results:
            continue
        compare = run.get('compare')
        if not compare:
            continue
        base = results.get(compare['label'])
        current = results[label]
        if base is None:
            current['info'].append(
                f'comparison skipped: run {compare["label"]!r} was not verified'
            )
            continue
        mode = compare['mode']
        if mode == 'identical':
            if current['lines'] != base['lines']:
                current['problems'].append(
                    f'output is not deterministic compared with {compare["label"]!r}'
                )
        elif mode == 'records':
            current_set = {record_key(record) for record in current['records']}
            base_set = {record_key(record) for record in base['records']}
            if current_set != base_set:
                current['problems'].append(
                    f'violations differ from {compare["label"]!r}'
                )
        elif mode == 'subset':
            filtered = {
                record_key(record)
                for record in base['records']
                if record['file'] == compare['file']
            }
            current_set = {record_key(record) for record in current['records']}
            if current_set != filtered:
                current['problems'].append(
                    f'selected-file run does not match {compare["label"]!r} '
                    f'restricted to {compare["file"]}'
                )
        elif mode == 'drift':
            current_set = {record_key(record) for record in current['records']}
            base_set = {record_key(record) for record in base['records']}
            added = sorted(current_set - base_set)
            removed = sorted(base_set - current_set)
            if added:
                current['info'].append(
                    f'{len(added)} violation(s) only in the checkout under test: '
                    f'{added[:3]}'
                )
            if removed:
                current['info'].append(
                    f'{len(removed)} violation(s) only in the baseline: '
                    f'{removed[:3]}'
                )

    for key in ('repo', 'target'):
        before = manifest[key]
        now = snapshot(Path(before['path']))
        if now['head'] != before['head'] or now['dirty'] != before['dirty']:
            global_problems.append(
                f'{key} changed since prepare ({before["path"]}); '
                'nothing in the consumer or the checkout may be edited'
            )

    failures = 0
    diagnostics = 0
    for label, result in results.items():
        failed = bool(result['problems'])
        failures += 1 if failed else 0
        if failed:
            status = 'FAIL'
        elif result['source'] == 'baseline':
            status = 'INFO'
        elif result['kind'] == 'diagnostic':
            status = 'DIAG'
            diagnostics += 1
        else:
            status = 'PASS'
        detail = (
            f'kind={result["kind"]:<10} exit={result["exit"]} '
            f'mode={result["mode"]} violations={result["count"]} '
            f'files={result["files"]}'
        )
        print(f'{status:4} {label:22} {detail}')
        for problem in result['problems']:
            print(f'       - {problem}')
        for note in result['info']:
            print(f'       i {note}')

    for problem in global_problems:
        print(f'FAIL environment: {problem}')

    total = len(results)
    print(
        f'RESULT: {total - failures}/{total} scenarios passed'
        + (f' ({failures} failed)' if failures else '')
    )
    if diagnostics:
        print(
            f'DIAG: {diagnostics} malformed-consumer observation(s) — '
            'report any unhandled exception or unexpected message as a finding'
        )
    print(f'artifacts: {art}')

    verify_report = {
        'generatedAt': time.strftime('%Y-%m-%dT%H:%M:%S%z'),
        'results': list(results.values()),
        'problems': global_problems,
        'passed': not failures and not global_problems,
    }
    write_json(art / 'verify.json', verify_report)
    return 0 if (not failures and not global_problems) else 1


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------


def build_parser():
    parser = argparse.ArgumentParser(
        description='Validate the eagle_eye checkout against a consumer project.'
    )
    subparsers = parser.add_subparsers(dest='command', required=True)

    prepare = subparsers.add_parser(
        'prepare', help='validate inputs and write scenario configs + manifest'
    )
    prepare.add_argument(
        '--target', required=True, help='consumer project root (contains pubspec.yaml)'
    )
    prepare.add_argument(
        '--art', required=True, help='scratch/artifact directory (outside both repos)'
    )
    prepare.add_argument('--repo', help='eagle_eye checkout (defaults to this repo)')
    prepare.add_argument('--dart', help='Dart SDK binary to use')
    prepare.add_argument(
        '--file',
        help='consumer file with internal imports to use as the hero file',
    )
    prepare.set_defaults(func=cmd_prepare)

    run = subparsers.add_parser('run', help='execute every scenario and capture output')
    run.add_argument('--art', required=True)
    run.add_argument('--dart', help='override the Dart SDK recorded by prepare')
    run.set_defaults(func=cmd_run)

    verify = subparsers.add_parser('verify', help='validate the captured runs')
    verify.add_argument('--art', required=True)
    verify.add_argument(
        '--only', action='append', help='verify only the given label (repeatable)'
    )
    verify.set_defaults(func=cmd_verify)

    return parser


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == '__main__':
    raise SystemExit(main())
