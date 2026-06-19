---
name: architecture
description: Verify architectural consistency and dependency rules in EagleEye
trigger: when the user asks about architecture, rules, conventions, or what is/isn't allowed in the codebase
---

# EagleEye — Architectural Rules & Conventions

## Architectural Rules — Never Violate

1. **Layer separation is strict.** `lib/model/` depends on nothing. `lib/data/` may depend on `model/`. `lib/analyzer/` may depend on `model/`, `data/`, and `util/`. `lib/util/` depends on nothing.

2. **No cyclic dependencies** between `lib/` subdirectories.

3. **`bin/main.dart` only accesses the public API.** Never import internal modules directly from the CLI entry point.

4. **Public API should be minimal and intentional.** Internal implementation details should not be exposed.

5. **Files outside `lib/`** (e.g., `bin/`, `test/`) should not be imported by `lib/`.

6. **`lib/util/` should be independent** of other layers — no imports from `model/`, `data/`, or `analyzer/`.

7. **Test files mirror the `lib/` structure.** `test/analyzer/` mirrors `lib/analyzer/`, `test/model/` mirrors `lib/model/`.

## Code Conventions

- **Dart:** follows official Dart conventions. `snake_case` for files, `lowerCamelCase` for variables/functions, `UpperCamelCase` for classes.
- **Imports:** prefer `package:` imports over relative. `avoid_relative_lib_imports` is enforced.
- **Tests:** `package:test` framework. Descriptive test names, `group()` for logical grouping.
- **Commits:** messages in English, semantic (`feat:`, `fix:`, `test:`, `chore:`, `docs:`).

## What NOT to Do

- Do not add platform dependencies in `lib/` (Dart CLI only)
- Do not create cyclic dependencies between `lib/` subpackages
- Do not commit `local.properties` or credential files
- Do not use `--no-verify` to bypass CI hooks
- Do not expose internal implementation as public API
