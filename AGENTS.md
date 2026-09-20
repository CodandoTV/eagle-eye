# EagleEye

Dart CLI that detects architecture violations in Dart projects by scanning
`lib/` imports against rules in `eagle_eye_config.json`.
Docs: https://codandotv.github.io/eagle-eye/ · Package: `eagle_eye` on pub.dev.

## Commands

Always run from the repo root.

```bash
dart pub get                    # install deps
dart analyze                    # static analysis (fails build on lint errors)
dart test                       # run all tests
dart test test/model/eagle_eye_config_item_test.dart   # single file
dart test -n "returns null"     # single test by name
dart run eagle_eye:main         # run the CLI against the current project
```

CI (`pr.yml`) runs `dart test` then `dart analyze` on PRs to `main`; both must
pass. Run `dart analyze && dart test` after any change before calling it done.

## Linting is strict — most common agent mistake

`analysis_options.yaml` includes `flutter_lints` and escalates the following to
**errors** (not warnings), so `dart analyze` fails on any of them:

- `public_member_api_docs` — every public member in `lib/` needs a `///` doc comment
- `lines_longer_than_80_chars`
- `prefer_single_quotes`
- `always_use_package_imports` — no relative imports inside `lib/`
- `directives_ordering`
- `always_declare_return_types`, `prefer_final_fields`, `prefer_const_constructors`
- `annotate_overrides`, `curly_braces_in_flow_control_structures`, `file_names`
- `avoid_print`, `avoid_relative_lib_imports`, `avoid_multiple_declarations_per_line`

## Architecture

Public entry point is `lib/eagle_eye_launcher.dart`
(`EagleEyeLauncher().launchEagleEye()`); `bin/main.dart` only calls it.

Layer rules (enforced by convention, checked in `.opencode/module-graph.md`):

- `lib/model/` — zero internal deps
- `lib/util/` — zero internal deps
- `lib/data/` — may depend on `model/`
- `lib/analyzer/` + `lib/analyzer/checker/` — may depend on `model/`, `data/`, `util/`
- no cycles; `bin/` must only touch the public entry point

## Runtime behavior

`launchEagleEye()` reads `eagle_eye_config.json` from the project root, gets the
app name from `pubspec.yaml`, scans `lib/`, and `exit(1)` on violations or
missing config/app name. Config is a JSON array of items with keys:
`filePattern`, `name`, `dependenciesAllowed`, `forbiddenDependencies`,
`exclusiveDependencies` (these were renamed in 2.0.0).

## Version & release

- Version lives in `pubspec.yaml` (currently `2.0.4`) and `CHANGELOG.md`.
- Release = bump version + changelog, commit, tag `vX.Y.Z`, push. The tag
  triggers `publish.yml` (pub.dev via OIDC). Use the `trigger-release` skill.

## AI context

- `AGENTS.md` is the single source of truth; opencode loads it via
  `opencode.json`.
- Skills live in `.opencode/skills/` and are auto-loaded by opencode's native
  skill scan. Before a task, check for a matching skill (e.g. `testing`,
  `review-pr`, `trigger-release`, `architecture`) and read it in full.
- Warning: `.opencode/instructions/dart.md` references class/file paths that no
  longer exist (e.g. `lib/analyzer/analyzer.dart`, `checker/checker.dart`).
  Trust the actual `lib/` tree over it.
