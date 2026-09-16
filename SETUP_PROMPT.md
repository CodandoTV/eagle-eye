# Set Up Eagle Eye in a Flutter/Dart Project

You are setting up [Eagle Eye](https://pub.dev/packages/eagle_eye), a Dart CLI tool that detects architecture violations in Dart projects. Follow the steps below to configure it for the target project.

---

## Step 1: Gather project context

Read `pubspec.yaml` in the project root to extract:

- **App name** (`name:` field) — used to identify internal imports
- **SDK constraint** (`environment.sdk`) — must be `^3.8.0` or higher
- **Existing dependencies** — check if `eagle_eye` is already present

Then scan the `lib/` directory tree. List all subdirectories and file patterns to understand the architecture. Look for:

| Signal | Likely pattern |
|---|---|
| `lib/` has `data/`, `domain/`, `presentation/` | Clean Architecture |
| `lib/` has `data/`, `domain/`, `ui/` or `views/` | Clean Architecture (variant) |
| Files named `*viewmodel.dart`, `*screen.dart` | MVVM |
| Files named `*_cubit.dart`, `*_state.dart` | BLoC / Cubit |
| Files named `*_controller.dart` | GetX or Controller-based |
| Files named `*_provider.dart`, `*_notifier.dart` | Provider / Riverpod |
| Directories named by feature (e.g. `auth/`, `home/`) | Feature-based |
| `lib/` has `models/`, `repositories/`, `services/`, `utils/` | Layer-based |

---

## Step 2: Generate `eagle_eye_config.json`

Create the file at the **project root** (same directory as `pubspec.yaml`). The file is a JSON array of rule objects.

### Rule types

| Key | Type | Effect |
|---|---|---|
| `filePattern` | string | Wildcard pattern matching file paths. `*` becomes `.*` regex. |
| `dependenciesAllowed` | boolean | If `false`, matched files must have **zero** internal imports. |
| `forbiddenDependencies` | string[] | Matched files **must not** import anything matching these patterns. |
| `exclusiveDependencies` | string[] | Matched files can **only** import things matching these patterns. |
| `name` | string | Optional human-readable name (shown in violation output). |

### Architecture-specific rule templates

Based on what you detected in Step 1, pick and adapt the relevant template(s).

#### Clean Architecture (`data/`, `domain/`, `presentation/`)

```json
[
  {
    "filePattern": "*/domain/model/*",
    "dependenciesAllowed": false,
    "name": "domain-models-no-imports"
  },
  {
    "filePattern": "*/domain/*_repository.dart",
    "exclusiveDependencies": ["*/data/*"],
    "name": "repositories-only-data"
  },
  {
    "filePattern": "*/presentation/*",
    "forbiddenDependencies": ["*/data/*"],
    "name": "presentation-no-data"
  }
]
```

#### MVVM (`*viewmodel.dart`, `*screen.dart`)

```json
[
  {
    "filePattern": "*viewmodel.dart",
    "forbiddenDependencies": ["*_screen.dart"],
    "name": "viewmodels-no-screens"
  },
  {
    "filePattern": "*screen.dart",
    "exclusiveDependencies": ["*_viewmodel.dart", "*_widget.dart"],
    "name": "screens-only-widgets-and-viewmodels"
  }
]
```

#### Feature-based (directories named by feature)

```json
[
  {
    "filePattern": "*/features/*/data/*",
    "exclusiveDependencies": ["*/features/*/domain/*"],
    "name": "feature-data-depends-on-domain"
  },
  {
    "filePattern": "*/features/*/domain/*",
    "dependenciesAllowed": false,
    "name": "feature-domain-no-imports"
  }
]
```

#### Generic / starter config

If the architecture is unclear or doesn't match a specific pattern, use this conservative starter:

```json
[
  {
    "filePattern": "*/model/*",
    "dependenciesAllowed": false,
    "name": "models-no-imports"
  },
  {
    "filePattern": "*/data/*_repository.dart",
    "exclusiveDependencies": ["*_datasource.dart"],
    "name": "repositories-only-datasources"
  }
]
```

### Customization guidelines

- Start with a small set of rules (2-4). You can add more as your architecture stabilizes.
- `filePattern` matches against the full file path relative to `lib/`. Use `*` as a wildcard.
- Rules are evaluated in order; **first matching rule wins** for each file.
- Only **internal imports** (those containing your app name) are checked. External package imports are ignored.
- Each rule object should have **at most one** of: `dependenciesAllowed`, `forbiddenDependencies`, or `exclusiveDependencies`.

---

## Step 3: Configure `analysis_options.yaml`

Eagle Eye requires package-style imports (not relative imports). Ensure this lint rule is set to `error`.

**If the file does not exist**, create it:

```yaml
analyzer:
    errors:
        avoid_relative_lib_imports: error
```

**If the file already exists**, add or merge the `errors` section:

```yaml
analyzer:
    errors:
        avoid_relative_lib_imports: error
        # ... other existing error rules
```

This enforces imports like:
```dart
// GOOD - package import
import 'package:my_app/utils/helper.dart';

// BAD - relative import
import '../utils/helper.dart';
```

---

## Step 4: Add Eagle Eye dependency

Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
    # ... existing dev dependencies
    eagle_eye: ^2.0.4
```

Then run:

```bash
dart pub get
```

Or for Flutter projects:

```bash
flutter pub get
```

---

## Step 5: Validate the setup

Run the CLI:

```bash
dart run eagle_eye:main
```

- **Exit code 0** with a success message: setup is correct.
- **Exit code 1** with violations listed: the rules are working — review the violations to confirm they are real issues or adjust your config.

---

## Step 6: Optional — integrate into CI/CD

Add to your CI pipeline (e.g. GitHub Actions, GitLab CI):

```yaml
- name: Check architecture rules
  run: dart run eagle_eye:main
```

Eagle Eye exits with code 1 on violations, so the CI step will fail automatically if architecture rules are broken.

---

## Summary of files to create/modify

| File | Action | Purpose |
|---|---|---|
| `eagle_eye_config.json` | Create | Architecture rules |
| `analysis_options.yaml` | Create or modify | Enable `avoid_relative_lib_imports: error` |
| `pubspec.yaml` | Modify | Add `eagle_eye` as dev dependency |

After completing all steps, run `dart run eagle_eye:main` to confirm everything works.
