---
name: architecture
description: EagleEye architectural rules, layer boundaries, and how to audit the dependency graph. Use when the user asks about architecture, dependency rules, conventions, or whether a change is allowed.
whenToUse: Deciding where new code belongs, checking whether an import is allowed, or auditing lib/ for cycles and layer violations.
---

# EagleEye — Architectural Rules & Conventions

## Architectural Rules — Never Violate

1. **Layer separation is strict.** `lib/model/` depends on nothing. `lib/util/`
   depends on nothing. `lib/data/` may depend on `model/`. `lib/analyzer/` may
   depend on `model/`, `data/`, and `util/`.

2. **No cyclic dependencies** between `lib/` subdirectories.

3. **`bin/main.dart` only accesses the public API.** Never import internal
   modules directly from the CLI entry point.

4. **Public API should be minimal and intentional.** Internal implementation
   details should not be exposed.

5. **Files outside `lib/`** (e.g. `bin/`, `test/`) must not be imported by
   `lib/`.

6. **Test files mirror the `lib/` structure.** `test/analyzer/` mirrors
   `lib/analyzer/`, `test/data/` mirrors `lib/data/`.

## Auditing the Dependency Graph

When asked to validate architecture, produce a report rather than a running
commentary:

1. Map the layout of `lib/` (the current subdirectories are `analyzer/`,
   `data/`, `model/`, `util/`, plus `eagle_eye_launcher.dart` and
   `service_locator.dart` at the root).
2. Collect imports across package boundaries: which `lib/` subdirectory imports
   which.
3. Check each rule above, plus these layer-specific ones:
   - `lib/data/` must not import `analyzer/` or `util/`.
   - `lib/util/` must not import `model/`, `data/`, or `analyzer/`.
4. Look for violations (cycles, forbidden edges, internal-leak imports, unused
   files) and warnings (broad exports, files with too many dependencies,
   unclear responsibilities).
5. Report under three headings: **Violations** (critical, breaks a rule),
   **Warnings** (smells), **Recommendations**.

`.opencode/module-graph.md` records the expected graph; trust the `lib/` tree
over it if they disagree.

## Code Conventions

- **Dart:** official Dart conventions. `snake_case` files, `lowerCamelCase`
  variables/functions, `UpperCamelCase` classes.
- **Imports:** `package:` imports, never relative inside `lib/`.
- **Tests:** `package:test`, descriptive names, `group()` for grouping.
- **Commits:** English, semantic (`feat:`, `fix:`, `test:`, `chore:`, `docs:`).
- **Lints are errors, not warnings.** `public_member_api_docs`,
  `lines_longer_than_80_chars`, `prefer_single_quotes`,
  `always_use_package_imports`, `directives_ordering`, and friends all fail
  `dart analyze`.

## What NOT to Do

- Do not add platform dependencies in `lib/` (Dart CLI only).
- Do not create cyclic dependencies between `lib/` subpackages.
- Do not commit `local.properties` or credential files.
- Do not use `--no-verify` to bypass CI hooks.
- Do not expose internal implementation as public API.
