---
name: run-build
description: Run the EagleEye build and tests
trigger: when the user asks to build, compile, run tests, or validate the project
---

# Running the EagleEye Build

## Commands

Always run from the project root:

```bash
# Install dependencies
dart pub get

# Static analysis
dart analyze

# Run tests
dart test

# Run the CLI locally
dart run eagle_eye:main

# Publish to pub.dev
dart pub publish
```

## When to Run

Per AGENTS.md rules: **run `dart analyze` and `dart test` after every task before marking it complete**. Never mark a task complete without a passing build.

## Common Errors

| Error | Likely Cause | Fix |
|---|---|---|
| `Undefined name` | Missing import | Add the correct `package:` import |
| `The method doesn't override an inherited method` | Wrong method signature | Check the base class/interface |
| `Target of URI doesn't exist` | Wrong file path in import | Fix the import path |
| `A value of type X can't be assigned to Y` | Type mismatch | Check the expected type |
| Test failures | Logic error or outdated expectation | Debug and fix the implementation |

## CI Pipeline

The project has three CI workflows (see `.github/workflows/`):

- **`pr.yml`** — runs `dart test` and `dart analyze` on every PR to `main`
- **`documentation.yml`** — deploys MkDocs site
- **`publish.yml`** — publishes to pub.dev
