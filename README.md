# EagleEye

**EagleEye** is a Dart CLI tool for **detecting architecture violations** in Dart projects.  

> ⚠️ **Note:** This tool is under active development and **not yet production-ready**.

---

## Features

- Analyze Dart project files for architectural rules.
- Detect forbidden dependencies based on configurable patterns.
- Lightweight CLI, easy to integrate into your project workflow.

---

## Installation

### 1. Clone the repository:

```bash
git clone <repository-url>
cd eagle_eye
```

### 2. Add EagleEye to your project in `pubspec.yaml`:

```yaml
dependencies:
  eagle_eye:
    path: ../eagle_eye
```

## Usage

Create a JSON file in your project to define rules. Example:

```json
[
  {
    "filePattern": "*util.dart",
    "noDependsEnabled": true
  },
  {
    "filePattern": "*screen.dart",
    "noDepsWithPatterns": ["*repository.dart"]
  }
]
```

In the example above, we define two rules:
- Any file ending with the `util.dart` suffix must not have dependencies.
- Any screen file must not directly depend on repository classes — instead, it should access data through a ViewModel (for example).

Add it in the root level of your project.

> filePattern – glob pattern to match files.
> 
> noDependsEnabled – set to true to forbid dependencies for matching files.

Run the eagle eye locally:

```sh
dart run eagle_eye:main
```

