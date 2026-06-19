---
name: review-pr
description: Review an EagleEye pull request checking architecture, tests, docs, and completeness
trigger: when the user asks to review a PR, check a pull request, or validate changes
---

# EagleEye PR Review Checklist

## 1. Architectural Rules

- [ ] No cyclic dependencies between `lib/` subdirectories
- [ ] Layer separation respected: `model/` → `data/` → `analyzer/` → `checker/`
- [ ] `lib/util/` has no internal dependencies
- [ ] `bin/main.dart` only accesses the public API

## 2. Tests

- [ ] Unit tests present for new code
- [ ] Test file naming: `<name>_test.dart` matching `<name>.dart`
- [ ] Tests use `package:test` framework
- [ ] Edge cases and error paths covered

## 3. Documentation

- [ ] `doc/` updated if public behavior changed
- [ ] `README.md` updated if needed
- [ ] `CHANGELOG.md` updated if needed

## 4. Code Standards

- [ ] Follows Dart conventions
- [ ] No private API leaks (internal implementation not exposed)
- [ ] Imports use `package:` style (no relative `lib/` imports)
- [ ] Commit messages are semantic (`feat:`, `fix:`, `test:`, `chore:`, `docs:`)
