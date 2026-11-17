---
name: consumer-app-test
description: Use when validating the eagle_eye checkout against a real Dart/Flutter consumer project end-to-end — runs the local CLI from the consumer root, exercises every rule type and CLI path with temporary configs kept outside the consumer, checks exit codes and the line-level violation report, compares with the released baseline the consumer pins, and never edits the consumer. Triggers on "validate eagle_eye locally", "test with a consumer app", "consumer smoke test", "check eagle_eye against a project", "does this change break a real project".
whenToUse: Proving a change works in a real project before release, or hunting consumer-facing issues (false positives/negatives, wrong exit codes, crashes, misleading errors, path-selection bugs).
---

# Consumer App Test

Validates eagle_eye **as checked out here** against a consumer Dart/Flutter
project, without publishing or touching the consumer. Use it to prove a
consumer-facing change (rule engine, report, CLI flags, path handling,
configuration validation) works in a real project, or to hunt for issues before
a release.

The consumer is an **input, never a constant**: always ask for it unless the
user already named it in the request. `../todoapp_flutter` is the example
consumer used to build this skill — never default to it.

## Inputs to collect first

1. **Consumer project path** — the directory containing `pubspec.yaml` and
   `lib/`. Relative or absolute both work.
2. **Baseline** — automatic: whatever `eagle_eye` the consumer already resolves
   in `.dart_tool/package_config.json`. If the consumer does not depend on
   eagle_eye, there is no baseline; the local run still works.
3. **Post results to a PR?** — only when the user asked. Posting is public.

Everything the skill generates goes to one scratch directory:
`ART=$(mktemp -d)`. Print `$ART` in the final report. Never create artifacts
inside the consumer or inside this repo.

## Step 0 — Validate inputs and snapshot

```bash
REPO=$(git rev-parse --show-toplevel)
SKILL="$REPO/.opencode/skills/consumer-app-test"
ART=$(mktemp -d)
python3 "$SKILL/scripts/consumer_check.py" prepare \
  --target <consumer-project> --art "$ART"
```

`prepare` fails with `ERROR: ...` and fixes nothing when the consumer is not
usable (no `pubspec.yaml`/`name:`, no `lib/` with Dart files) or when the local
checkout is not resolvable. On success it prints and records in
`$ART/manifest.json`:

- target and this checkout, each with git `HEAD` and `status --porcelain`
  (the snapshot the skill must not change);
- proof that `.dart_tool/package_config.json` resolves `eagle_eye` to this
  checkout;
- the Dart SDK it will use and why others were rejected;
- the baseline version/root, or why there is no baseline;
- an **independent oracle** of the consumer: internal imports and the files
  that contain them, plus a hero file to use for single-file scenarios.

It also writes the scenario configs under `$ART/configs/` and two scratch
projects under `$ART/scratch/` (`no-lib`, `no-pubspec`). None of that touches
the consumer.

`prepare` resolves a standalone Dart SDK and deliberately **skips asdf shims
and the `flutter/bin/dart` wrapper**: those resolve per cwd and try to write the
Flutter SDK cache, which fails under the file sandbox
(`update_engine_version.sh ... Operation not permitted`). Pass `--dart
/path/to/dart` if discovery fails; record the path in the report.

If the repo has no `.dart_tool/package_config.json`, run `dart pub get` **in
this repo only** and retry. Never run `dart pub get`/`flutter pub get` in the
consumer.

## Step 1 — Run the CLI from this checkout

The CLI reads `eagle_eye_config.json`, `lib/`, and `pubspec.yaml` from the
**current directory** and has no target-path option. Set `DART` to the binary
`prepare` printed (for example
`DART=$HOME/.asdf/installs/dart/3.12.2/bin/dart`), then run it with the consumer
as cwd while package resolution comes from this checkout:

```bash
cd "$TARGET"
"$DART" \
  --packages="$REPO/.dart_tool/package_config.json" \
  "$REPO/bin/main.dart" \
  --config "$ART/configs/positive.json"
```

This runs the working tree as-is (uncommitted changes included), needs no
publish, no `pub get` in the consumer, and no consumer dependency edit. Do not
use `dart run eagle_eye:main` from the consumer: for Flutter consumers it
triggers implicit pub resolution and fails, and it re-resolves through the shim
that Step 0 exists to avoid.

The configs the skill uses all live under `$ART/configs/`, so the consumer is
only ever read. An example single scenario is saved as
`$ART/<label>.cmd`; use it to reproduce a failure manually.

## Step 2 — Run the scenario matrix

```bash
python3 "$SKILL/scripts/consumer_check.py" run --art "$ART"
```

Each run captures `<label>.stdout`, `<label>.stderr`, `<label>.exit`, and
`<label>.cmd` under `$ART`. Expected non-zero exits are normal and are not
failures. Labels:

| label | proves |
|---|---|
| `default` | the consumer's own config runs (or the missing-config error) |
| `positive` | `exclusiveDependencies` catches every internal import |
| `forbidden` | `forbiddenDependencies` catches only the imports it names |
| `no-imports` | `dependenciesAllowed: false` reports every internal import |
| `pass` | a satisfied config exits 0 with the success message |
| `verbose` | `--verbose` changes tracing, not the verdict |
| `determinism` | two identical runs print byte-identical reports |
| `files-hit` | a positional `lib/...` path reports only that file |
| `files-abs` | an absolute path selects the same file |
| `files-dup` | a repeated path is deduplicated |
| `files-missing` | a missing path fails with a clear error |
| `files-outside` | a non-Dart path fails with a clear error |
| `conflict` | two rules matching one file are rejected before analysis |
| `deprecated-key` | removed config keys are rejected with the migration hint |
| `backslash-pattern` | a Windows-style `filePattern` is rejected |
| `missing-config` | an absent `-c` file fails with a clear error |
| `help` | `--help` exits 0 and lists every flag |
| `unknown-flag` | an unknown flag fails with a clear error |
| `no-lib` | a directory without `lib/` fails with a clear error |
| `no-pubspec` | a malformed consumer is handled (DIAG, see Step 3) |
| `baseline-default` | the version the consumer pins, same consumer config |

Counts for `positive`/`forbidden`/`no-imports` and the expected file set come
from the oracle in Step 0, so they adapt to the consumer; they are not
hard-coded. `--file lib/some/file.dart` picks a different hero file.

## Step 3 — Verify every capture

```bash
python3 "$SKILL/scripts/consumer_check.py" verify --art "$ART"
```

`verify` exits 0 only when every local scenario passes, and writes
`$ART/verify.json`. `--only <label>` (repeatable) checks a subset. It enforces:

- exact exit code per scenario (`0` success/help, `1` violations/errors);
- the report structure: file groups sorted and unique, one rule line per
  violation, `N errors in M files` equal to the parsed rows;
- every reported `lib/` file exists and the reported 1-based line really
  contains `import '<uri>';`, and the URI really is internal (contains the
  consumer's `name:`);
- violation counts, distinct files, per-type histogram, and file set equal the
  oracle expectation;
- `verbose` reports the same violations as `positive`; two identical runs are
  byte-identical; selected-file runs equal the `positive` subset;
- no stack trace, `Unhandled exception`, `PathAccessException`, or Dart
  wrapper/SDK noise, and empty stderr for local runs;
- both git snapshots are unchanged since `prepare` — a changed consumer is a
  failure, not a warning.

Triage:

| observation | finding |
|---|---|
| expected vs actual count/files differ | false positive/negative — check the reported line and import before blaming the tool |
| unhandled exception, stack trace, exit 255 | crash bug (include the failing `.cmd`) |
| error message missing or not the documented one | UX/error-handling bug |
| `determinism` differs | nondeterministic report |
| `verbose` differs from `positive` | verbose mode changes behavior |
| `files-hit`/`files-abs`/`files-dup` differ | file selection / path normalization bug |
| `DIAG` line | malformed-consumer robustness observation; list it as a minor finding, it does not fail the run |

`DIAG` exists only for `no-pubspec`: the tool intends a friendly
"Unable to detect the name of you app" error there. If it instead prints an
unhandled exception, that is a real (minor) defect — record it, but do not
"fix" the synthetic consumer to silence it.

## Step 4 — Baseline drift

`baseline-default` runs the version the consumer pins, using the consumer's own
config. `verify` lists violations that appear only in the checkout under test
or only in the baseline as `INFO`; it never fails on them. Every difference must
be explained by the change under test or by `CHANGELOG.md`; otherwise report it
as a regression. If the consumer pins an old version, the baseline may not
support `--config`/`--verbose`; that is expected, since the baseline run uses
only the default config.

## Step 5 — Cleanup

There is nothing to revert in the consumer: all configs and scratch projects
live under `$ART`, and `verify` already proved both git snapshots are unchanged
(confirm with `git -C "$TARGET" status --porcelain` anyway). Only if the user
explicitly asked to exercise default-config discovery on a consumer without
`eagle_eye_config.json` may you create that file temporarily — verify it did
not exist first, then delete exactly that absolute path. Keep `$ART` as
evidence; do not delete it.

## Step 6 — Report

Summarise:

- environment: OS, Dart version/binary, consumer path + `HEAD` + dirty state,
  this checkout `HEAD`/branch + dirty state, baseline version (or why none);
- scenario table: label, exit code, violations/files, PASS/FAIL/DIAG;
- findings grouped by severity (crash, wrong exit code, false
  positive/negative, misleading error, nondeterminism, robustness note), each
  with the `.cmd` and the captured output;
- baseline drift and its explanation;
- limitations (what the scenario matrix cannot reach, e.g. Windows-only path
  handling on macOS; exports/parts are not analyzed);
- the `$ART` artifacts path.

Post to the PR only if the user asked:

```bash
gh pr comment <number> --repo <owner>/<repo> --body-file "$ART/pr-comment.md"
```

## Rollback when a step fails

Do not post anything, do not edit the consumer to make a scenario green, and do
not delete `$ART`. Report the failing command (`.cmd`), its exit code, and the
captured stdout/stderr. A failure in `prepare` is usually a wrong consumer path
or a missing `dart pub get` in this repo — say which.

## Notes

- eagle_eye only analyzes `import` directives; `export`, `part`, and relative
  imports that do not contain the app name are outside its model. A file with
  zero internal imports produces no violations for any rule.
- "Internal" means the import URI contains the `name:` from `pubspec.yaml`
  (substring match), not a resolved package graph.
- The oracle counts internal imports that start at column 0 (dart-format style).
  A consumer with hand-indented import directives can make the expected count
  differ from the AST-based run; confirm the source before calling it a bug.
- ANSI colour codes are always emitted, even when stdout is piped; the checker
  strips them. Do not parse raw output by hand.
- Commands touch the consumer directory and the build cache, which are outside
  this repo's workspace. In sandboxed agents they need wider file-access
  approval; request it rather than copying the consumer into the repo.
- The full flow takes about a minute (roughly 3–4 s per scenario).
