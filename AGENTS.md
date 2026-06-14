# EagleEye

## Project Overview

EagleEye is a Dart CLI tool for detecting architecture violations in Dart projects. It analyzes Dart project files against configurable architectural rules to enforce dependency boundaries and layering.

- **Library type:** Dart Package (CLI tool)
- **Primary language:** Dart ^3.8.0
- **Runtime/platform:** Dart CLI
- **Repository:** https://github.com/CodandoTV/eagle-eye
- **Documentation:** https://codandotv.github.io/eagle-eye/

## Build System

- **Dart SDK constraint:** ^3.8.0 (defined in `pubspec.yaml:7`)
- **Dependencies defined in:** `pubspec.yaml`
- **Build and release commands:**
  - `dart pub get` — Install dependencies
  - `dart analyze` — Static analysis
  - `dart test` — Run tests
  - `dart run eagle_eye:main` — Run the CLI tool locally
  - `dart pub publish` — Publish to pub.dev

## Project Structure

```
bin/
  main.dart              — CLI entry point
lib/
  analyzer/              — Core analysis engine
    checker/             — Rule checkers
  data/                  — Data access layer
  model/                 — Domain models
    exceptions/          — Custom exceptions
  util/                  — Utilities
test/
  analyzer/              — Analyzer tests
    checker/             — Rule checker tests
  model/                 — Model tests
doc/                     — MkDocs documentation source
  index.md               — Documentation home
  img/                   — Documentation images
example/
  README.md              — Example usage guide
```

## Version Management

- **Version:** Defined in `pubspec.yaml` under the `version` field
- Current version: `2.0.2`

## Documentation

- **Generator:** MkDocs
- **Configuration:** `mkdocs.yml`
- **Source directory:** `doc/`
- **Theme:** Material for MkDocs
- **Live site:** https://codandotv.github.io/eagle-eye/

## Distribution

- **pub.dev package URL:** https://pub.dev/packages/eagle_eye
- **Package name:** `eagle_eye`

## Git Workflow

- **Default branch:** `main`
- **Release process:**
  1. Update version in `pubspec.yaml`
  2. Update `CHANGELOG.md`
  3. Commit changes
  4. Tag with `vX.Y.Z`
  5. Push commits and tags
  6. Publish to pub.dev (`dart pub publish`)
- **Git tag strategy:** `vX.Y.Z` (e.g., `v2.0.2`)
- **Versioning strategy:** Semantic Versioning (SemVer)
