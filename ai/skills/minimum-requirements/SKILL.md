---
name: minimum-requirements
description: Determine minimum requirements to consume the EagleEye library
trigger: when the user asks about minimum SDK version, requirements, or compatible Dart versions
---

# Minimum Requirements for EagleEye

When invoked:

1. Detect project type:
   - Check `pubspec.yaml` for `name:` and `environment:` fields to confirm Dart Package.
   - If `flutter:` dependency exists in `pubspec.yaml`, classify as Flutter Package.

2. Inspect dependency declarations:
   - Read `pubspec.yaml` — specifically the `environment:` section.

3. Determine minimum supported versions:

   ### Dart Package
   - Read `environment.sdk` from `pubspec.yaml` (e.g., `^3.8.0`).
   - Parse the minimum SDK version from the constraint.

   ### Flutter Package
   - Read `environment.sdk` and `environment.flutter` from `pubspec.yaml`.
   - Parse the minimum Flutter and Dart versions.

4. Create or update a section called `## Minimum Requirements` inside `README.md`.

   Example output:
   ```md
   ## Minimum Requirements

   ### Dart Package

   - Dart 3.8+
   ```
