---
name: testing
description: Write and review EagleEye tests following project conventions. Use when the user asks to write tests, add test cases, or review a test file.
whenToUse: Writing new tests, adding a regression test for a bug fix, or reviewing an existing test file.
---

# Testing in EagleEye

The project uses `package:test` (`^1.31.1`). Follow the existing suite rather
than inventing a style.

## 1. Detect the framework

- Read `pubspec.yaml` `dev_dependencies:` for `test`.
- If `flutter_test` appears, the project has become a Flutter package — confirm
  with the user before generating widget tests.

## 2. Read the existing suite first

- Skim `test/` before writing anything: note naming, the `group()`/`test()`
  shape, any helpers, and which matchers are already in use.
- Files are `<name>_test.dart` mirroring `<name>.dart` in `lib/`, and the
  directory tree mirrors `lib/`: `test/analyzer/`, `test/data/`, `test/util/`,
  plus `test/service_locator_test.dart`.
- Test names are descriptive lowercase phrases; assertions are
  `expect(actual, matcher)`.

## 3. Cover the right things

- Public classes and functions in `lib/`.
- Edge cases: null inputs, empty collections, invalid patterns.
- Error paths: exceptions and validation failures.
- Integration cases where relevant: end-to-end CLI execution, config loading
  and parsing.

## 4. Verify

- Run the new file first (`dart test test/<path>_test.dart`), then the full
  build per the `run-build` skill: `dart analyze && dart test`.
- Never report a test task complete on a failing build.
