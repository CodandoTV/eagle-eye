# EagleEye — Module Dependency Graph

## Module Structure

```
lib/
  model/         ← data classes, enums, exceptions (zero internal deps)
  data/          ← data access, serialization (depends on model/)
  analyzer/      ← analysis engine, rule checkers (depends on model/, data/)
    checker/     ← individual rule implementations (depends on model/)
  util/          ← shared utilities (zero internal deps)
bin/
  main.dart      ← CLI entry point (depends only on public API in lib/)
```

## Dependency Rules

```
                    ┌─────────────────────┐
                    │      lib/util/      │  ← no internal dependencies
                    └─────────────────────┘

                    ┌─────────────────────┐
                    │     lib/model/      │  ← no internal dependencies
                    └──────────┬──────────┘
                               │ depends on
                               ▼
                    ┌─────────────────────┐
                    │      lib/data/      │  ← depends on model/
                    └──────────┬──────────┘
                               │ depends on
                               ▼
                    ┌─────────────────────┐
                    │    lib/analyzer/     │  ← depends on model/, data/, util/
                    └──────────┬──────────┘
                               │ depends on
                               ▼
                    ┌─────────────────────┐
                    │  lib/analyzer/      │
                    │    checker/         │  ← depends on model/, analyzer/
                    └─────────────────────┘

  ✗ data/ → analyzer/        FORBIDDEN
  ✗ data/ → util/            FORBIDDEN
  ✗ model/ → data/           FORBIDDEN
  ✗ model/ → analyzer/       FORBIDDEN
  ✗ model/ → util/           FORBIDDEN
  ✗ bin/ → lib/* (internal)  FORBIDDEN (only public API entry point)
```

## Layer Responsibilities

| Layer | Role |
|---|---|
| `model/` | Data classes, enums, custom exceptions. Zero knowledge of other layers. |
| `data/` | Config loading, JSON parsing, file I/O. Depends on `model/` for types. |
| `analyzer/` | Core logic: walks files, resolves imports, checks rules. Orchestrates the analysis. |
| `analyzer/checker/` | Individual rule implementations. Each checker validates one rule type. |
| `util/` | Shared helpers (string, file, path utilities). No knowledge of project domain. |
| `bin/main.dart` | CLI entry point. Only calls the public API — never internal modules directly. |

## Adding a New Feature

1. If a new domain type is needed → add to `model/`
2. If data loading/parsing is needed → add to `data/`
3. If a new rule type is needed → add to `analyzer/checker/`
4. If a shared utility is needed → add to `util/`
5. Wire it up in `analyzer/` or `bin/main.dart`
