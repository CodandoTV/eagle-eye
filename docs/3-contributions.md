# Contributions 🤝

We encourage contributions of all types! Whether it's reporting issues, suggesting new features, or submitting pull requests, you're welcome to help improve the plugin.

- Check out the [issues](https://github.com/CodandoTV/eagle-eyeg/issues) page for ideas.

- Feel free to submit [pull requests](https://github.com/CodandoTV/eagle-eye/pulls).
### Publishing the library locally

!!!warning "Use JVM 17"
    Make sure your Gradle is using **JVM 17**, otherwise you could have some issues.

To run the plugin locally you need to publish it in your local machine using `mavenLocal`. 
You can follow the steps:

1- Update the `popcornguineapigplugin/build.gradle.kts` commenting the lines:

```kotlin
...
mavenPublishing {
    //publishToMavenCentral(SonatypeHost.CENTRAL_PORTAL)
    //signAllPublications()
    ...
```

2- Publish the plugin locally, using the command:

```shell
./gradlew :popcornguineapigplugin:publishToMavenLocal
```

After that, the plugin artifacts will be in your machine in the following path 
`$HOME/.m2/repository/io/github/codandotv/popcornguineapig/x.x.x`.

### Using the local library in any project

1- In your project, you can use by adding the `mavenLocal()` repository in the following places:

```kotlin
// settings.gradle.kts
pluginManagement {
    ...
    repositories {
        ...
        mavenLocal()
    }
}
```

```kotlin
// build-logic/build.gradle.kts
...
repositories {
    mavenLocal()
    // ...
}

dependencies {
    implementation("io.github.codandotv:popcornguineapig:x.x.x")
}
```

🤗 Happy coding!