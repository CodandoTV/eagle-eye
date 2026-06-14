---
name: generate-tests
description: Generate tests following project conventions
---

When invoked:

1. Detect testing framework:
   - Read `pubspec.yaml` `dev_dependencies:` for `test` (Dart `package:test`).
   - If `flutter_test` is found, classify as Flutter widget tests.
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
