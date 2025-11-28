# Getting started 🚀

## 1. Define rules

- In the root level of you project, you need to create the file `eagle_eye_config.json` at the root level of your flutter/dart project.

```json
[
  {
    "filePattern": "*/data/model/*",
    "noDependsEnabled": true
  },
  {
    "filePattern": "*viewmodel.dart",
    "doNotWithPatterns": ["*_screen.dart"]
  },
  {
    "filePattern": "*/util/*_handler.dart",
    "noDependsEnabled": true
  }
]
```

In my first rule, I’m telling Eagle Eye that no file under the `data/model` path should have dependencies.

The second rule states that my `ViewModels` must not depend on any screen-related files.

I also have a third rule that enforces that our handler classes should not have any dependencies at all.

## 2. Make sure you have a lint rule to avoid relative imports

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

## 3. Add Eagle Eye dependency

Add EagleEye to your project in `pubspec.yaml`:

```yaml
# versions available, run `flutter pub outdated`.
dev_dependencies:
    ...
    eagle_eye: ^version
```

## 4. Run the CLI

Now you can run the CLI, or integrate in your CI/CD pipeline as a required step.

```shell
dart run eagle_eye:main
```

--

Any problems you are facing, any suggestions you want to add, please feel free to [reach us out](mailto:gabrielbronzattimoro.es@gmail.com).