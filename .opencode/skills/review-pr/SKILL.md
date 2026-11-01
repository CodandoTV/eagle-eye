---
name: review-pr
description: Review an EagleEye pull request checking architecture, tests, docs, and completeness. Use when the user asks to review a PR, check a pull request, or validate changes.
whenToUse: Reviewing a branch or pull request before merge, or self-checking a change against the repo's standards.
---

# EagleEye PR Review Checklist

## 1. Architectural Rules

- [ ] No cyclic dependencies between `lib/` subdirectories
- [ ] Layer separation respected: `model/` and `util/` are leaf layers, `data/`
      may use `model/`, `analyzer/` may use `model/`, `data/`, and `util/`
- [ ] `lib/data/` does not import `analyzer/` or `util/`
- [ ] `lib/util/` has no internal dependencies
- [ ] `bin/main.dart` only accesses the public API

## 2. Tests

- [ ] Unit tests present for new code
- [ ] Test file naming: `<name>_test.dart` matching `<name>.dart`
- [ ] Tests use `package:test` framework
- [ ] Edge cases and error paths covered
- [ ] `dart analyze && dart test` pass (CI runs both)

## 3. Documentation

- [ ] `doc/` updated if public behavior changed
- [ ] `README.md` updated if needed
- [ ] `CHANGELOG.md` updated and the version matches `pubspec.yaml` when the
      change is user-visible

## 4. Code Standards

- [ ] Follows Dart conventions
- [ ] No private API leaks (internal implementation not exposed)
- [ ] Imports use `package:` style (no relative `lib/` imports)
- [ ] Every public member in `lib/` has a `///` doc comment
- [ ] Commit messages are semantic (`feat:`, `fix:`, `test:`, `chore:`, `docs:`)

Report findings grouped by file, with blocking issues separated from nits.
