# EagleEye

**EagleEye** is a Dart CLI tool for **detecting architecture violations** in Dart projects.  

> ⚠️ **Note:** This tool is under active development and **not yet production-ready**.

---

## Features

- Analyze Dart project files for architectural rules.
- Detect forbidden dependencies based on configurable patterns.
- Lightweight CLI, easy to integrate into your project workflow.

---

## How to install? 

### 1. Clone the repository:

```bash
git clone <repository-url>
cd eagle_eye
```

### 2. Add EagleEye to your project in `pubspec.yaml`:

⚠ We are working on a better way to distribute the library.

```yaml
dependencies:
  eagle_eye:
    path: ../eagle_eye
```

## How to use?

### 1. Make sure you have a lint rule to avoid relative imports

```yaml
# analysis_options.yaml

analyzer:
    errors:
        avoid_relative_lib_imports: error
```

In this way, we are forcing the internal imports to have the app name:

```dart
// BAD ❌ (relative import)
import '../utils/helper.dart';
```

```dart
// GOOD ✅ (package import)
import 'package:my_app/utils/helper.dart';
```

Ensure that this lint rule is enabled for EagleEye to function correctly.

### 2. In your project create a file `eagle_eye_config.json`

Create a JSON file in your project to define rules. Example:

```json
[
  {
    "filePattern": "*util.dart",
    "noDependsEnabled": true
  },
  {
    "filePattern": "*viewmodel.dart",
    "justWithPatterns": ["*repository.dart"]
  },
  {
    "filePattern": "*repository.dart",
    "doNotWithPatterns": ["*screen.dart"]
  }
]
```
Add the json file in the root level of your project.

Just to explain, we are defining some rules in this example:
- Any file ending with the `util.dart` suffix must not have dependencies;
- Any viewModel file should depend on repository classes;
- Any repository file should not depends on screen files.


### 3. Run the eagle eye locally:

```sh
dart run eagle_eye:main
```

If you have any error, the process will fail immediately.

⚠ We are working on error reports.

