---
name: validate-architecture
description: Verify architectural consistency and dependency rules
trigger: when the user asks about architecture, rules, conventions, or dependency validation
---

# Validate Architecture

When invoked:

1. Detect project structure:
   - Analyze `lib/` directory layout.
   - Identify internal packages and subdirectories (`analyzer/`, `data/`, `model/`, `util/`).
   - Note the `bin/` entry point.

2. Analyze dependencies between modules:
   - Map which `lib/` subdirectories import from which others.
   - Track imports across package boundaries.

3. Verify architecture rules for Dart packages:

   ### Package boundaries
   - Public API should be minimal and intentional.
   - Internal implementation details should not be exposed.
   - Files outside `lib/` (e.g., `bin/`, `test/`) should not be imported by `lib/`.

   ### Layer separation
   - `lib/model/` should have minimal dependencies (ideally none on other layers).
   - `lib/data/` may depend on `model/` but not on `analyzer/` or `util/`.
   - `lib/analyzer/` may depend on `model/` and `util/`.
   - `lib/util/` should be independent of other layers.
   - `bin/main.dart` should only depend on the public API entry point.

4. Detect:

   ### Violations
   - Cyclic dependencies between packages/modules.
   - Forbidden dependencies (e.g., data layer importing analyzer).
   - Unused modules or files.
   - Internal implementation leaks (private files imported externally).

   ### Warnings
   - Overly broad exports.
   - Files with too many dependencies.
   - Modules with unclear responsibilities.

5. Produce a report with:

   ### Violations
   Critical issues that break architectural rules.

   ### Warnings
   Potential issues or code smells.

   ### Recommendations
   Suggested improvements for the module structure and dependency graph.
