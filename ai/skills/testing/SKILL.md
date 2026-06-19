---
name: testing
description: Generate tests for EagleEye following project conventions
trigger: when the user asks to write tests, review test files, or generate new test cases
---

# Testing in EagleEye

When invoked:

1. Detect testing framework:
   - Read `pubspec.yaml` `dev_dependencies:` for `test` (Dart `package:test`).
   - This project uses `package:test` (`^1.31.1`).

2. Analyze existing tests in `test/`:
   - Read existing test files to determine naming conventions.
   - Note the use of `test()`, `group()`, `expect()` patterns.
   - Observe file naming (`*_test.dart` suffix).
   - Observe directory structure mirroring `lib/`.

3. Follow current naming conventions:
   - File names: `<name>_test.dart` matching `<name>.dart` in `lib/`.
   - Test names: descriptive strings, typically lowercase with spaces.
   - Use `group()` for logical grouping.
   - Use `test()` for individual test cases.
   - Use `expect(actual, matcher)` for assertions.

4. Generate unit tests for:
   - Public API classes and functions in `lib/`.
   - Edge cases (null inputs, empty collections, invalid patterns).
   - Error paths (exceptions, validation failures).

5. Generate integration tests when applicable:
   - End-to-end CLI execution tests.
   - Config file loading and parsing.

6. Ensure generated tests use the project's assertion style and test architecture:
   - Match existing `package:test` conventions.
   - Use the same matchers and patterns found in existing tests.

7. After writing tests, run `dart test` to verify they pass.
