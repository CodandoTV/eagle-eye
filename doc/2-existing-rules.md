# Existing rules 📐

We have several rules already defined in the plugin. You can create some rule too, take a look in our section about [contributions](./3-contributions.md).

## Forbidden Dependencies Rule

!!! warning "Deprecated - Only available before v2.0.0"

    The `DoNotWithRule` specifies that a set of file should not depend on certain files. For example:

    ```json
    // your-project-root/eagle_eye_config.json
    {
      "filePattern": "*viewmodel.dart",
      "doNotWithPatterns": ["*_screen.dart"]
    },
    ```

The `Forbidden Dependencies Rule` specifies that a set of file should not depend on certain files. For example:

```json
// your-project-root/eagle_eye_config.json
{
  "filePattern": "*viewmodel.dart",
  "forbiddenDependencies": ["*_screen.dart"]
},
```

In this case, all files that has the suffix `viewmodel.dart` should not depend on any file whose name includes '_screen.dart'.

## Exclusive Dependencies Rule

!!! warning "Deprecated - Only available before v2.0.0"

    The `JustWithRule` specifies that some files should depend on certain files. For example:

    ```json
    // your-project-root/eagle_eye_config.json
    {
      "filePattern": "*repository.dart",
      "justWithPatterns": ["*_datasources.dart"]
    },
    ```

The `Exclusive Dependencies Rule` specifies that some files should depend only on certain files. For example:

```json
// your-project-root/eagle_eye_config.json
{
  "filePattern": "*repository.dart",
  "exclusiveDependencies": ["*_datasources.dart"]
},
```

In this case, the our repositories should depend only on data sources.

## Dependencies Allowed Rule

!!! warning "Deprecated - Only available before v2.0.0"

    The `NoDependencyRule` ensures that some files should remain free of any dependencies. For example:

    ```json
      {
        "filePattern": "*util.dart",
        "noDependsEnabled": true
      },
    ```

The `Dependencies Allowed Rule` ensures that some files should remain free of any dependencies. For example:

```json
  {
    "filePattern": "*util.dart",
    "dependenciesAllowed": false
  },
```

In this case, the all utils should be free of any internal dependencies.