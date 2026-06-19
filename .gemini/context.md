# EagleEye — Gemini

> Read `AGENTS.md` at the start of every session for full project context.

EagleEye is a Dart CLI tool for detecting architecture violations in Dart projects.

## Critical Rules

- Dart CLI only — no platform dependencies in `lib/`
- No cyclic dependencies between `lib/` subdirectories
- `lib/model/` depends on nothing; `lib/data/` depends on `model/`; `lib/analyzer/` depends on `model/`, `data/`, and `util/`
- `lib/util/` has zero internal dependencies
- `bin/main.dart` only accesses the public API entry point
- Tests use `package:test` framework, naming: `<name>_test.dart`
- Commit messages: English, semantic (`feat:`, `fix:`, `test:`, `chore:`, `docs:`)
- Never expose internal implementation from `lib/` as public API

For complete rules and skills, read `ai/`.
