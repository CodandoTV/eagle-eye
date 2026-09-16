[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/CodandoTV/eagle-eye/issues)[![Pub Version](https://img.shields.io/pub/v/eagle_eye?style=flat)](https://pub.dev/packages/eagle_eye)

# EagleEye

**EagleEye** is a Dart CLI tool for **detecting architecture violations** in Dart projects.  

📚 Check our documentation [here](https://codandotv.github.io/eagle-eye/).

## Minimum Requirements

### Dart Package

- Dart 3.8+

---

## Features

- Analyze Dart project files for architectural rules.
- Detect forbidden dependencies based on configurable patterns.
- Lightweight CLI, easy to integrate into your project workflow.

---

## How to install?

```yaml
dev_dependencies:
    ...
    eagle_eye: ^version
```

## Getting Started

### Quick setup

1. **Enable the lint rule** in `analysis_options.yaml`:

```yaml
analyzer:
    errors:
        avoid_relative_lib_imports: error
```

2. **Create `eagle_eye_config.json`** at your project root:

```json
[
  {
    "filePattern": "*/model/*",
    "dependenciesAllowed": false,
    "name": "models-no-imports"
  },
  {
    "filePattern": "*viewmodel.dart",
    "forbiddenDependencies": ["*_screen.dart"],
    "name": "viewmodels-no-screens"
  }
]
```

3. **Add the dependency** to `pubspec.yaml`:

```yaml
dev_dependencies:
    eagle_eye: ^2.0.4
```

4. **Run it:**

```sh
dart run eagle_eye:main
```

### Auto-generate config with a prompt

You can use [this prompt](./SETUP_PROMPT.md) with an AI assistant to automatically detect your architecture and generate an `eagle_eye_config.json` with the right rules.

For the full setup guide with architecture-specific templates and customization guidelines, see the [Getting Started documentation](https://codandotv.github.io/eagle-eye/1-getting-started/).
