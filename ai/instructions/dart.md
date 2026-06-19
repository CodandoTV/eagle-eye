# Dart CLI — Platform Instructions

> Read this file when starting any EagleEye task.

---

## Core Abstractions

| Class/File | Role |
|---|---|
| `lib/analyzer/analyzer.dart` | Main analysis engine — walks files, resolves imports |
| `lib/analyzer/checker/` | Individual rule checkers |
| `lib/model/` | Domain models and exceptions |
| `lib/data/` | Config loading and data access |
| `lib/util/` | Shared utilities |
| `bin/main.dart` | CLI entry point |

## Architecture Overview

EagleEye works in three phases:

1. **Config loading** — reads `eagle_eye_config.json` from the project root
2. **File scanning** — walks Dart files in the target project, resolves imports
3. **Rule checking** — applies each rule from the config against the import graph

### Rule Engine

Rules are defined in JSON config:
```json
[
  {
    "filePattern": "*util.dart",
    "dependenciesAllowed": false
  },
  {
    "filePattern": "*viewmodel.dart",
    "exclusiveDependencies": ["*repository.dart"]
  },
  {
    "filePattern": "*repository.dart",
    "forbiddenDependencies": ["*screen.dart"]
  }
]
```

Each checker in `lib/analyzer/checker/` implements one rule type.

## Folder Structure

```
lib/
  analyzer/
    analyzer.dart            — main analysis engine
    checker/
      checker.dart           — base checker interface
      no_depends_checker.dart
      exclusive_depends_checker.dart
      forbidden_depends_checker.dart
      do_not_with_patterns_checker.dart
  data/
    config_loader.dart       — JSON config loading
    model/                   — internal data models
  model/
    analysis_result.dart
    violation.dart
    rule_config.dart
    exceptions/
  util/
    file_utils.dart
    import_resolver.dart
test/
  analyzer/
    analyzer_test.dart
    checker/
  model/
```

## Dart Conventions

- **Naming:** `snake_case` for files, `lowerCamelCase` for variables/functions, `UpperCamelCase` for classes
- **Imports:** Prefer `package:` imports over relative. `avoid_relative_lib_imports` is enforced
- **Testing:** `package:test` framework with descriptive test names
- **CLI:** `args` package for argument parsing, `stdout` for output, exit codes for success/failure

## Build

```bash
dart pub get    # install dependencies
dart analyze    # static analysis
dart test       # run tests
dart run eagle_eye:main  # run CLI locally
```

## Tests

- Framework: `package:test` (defined in `pubspec.yaml`)
- File naming: `<name>_test.dart` mirroring `<name>.dart` in `lib/`
- Test names: descriptive strings, lowercase with spaces
- Structure: `group()` for logical grouping, `test()` for individual cases
- Assertions: `expect(actual, matcher)`
