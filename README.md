# todoapp

![badge-android](http://img.shields.io/badge/platform-android-6EDB8D.svg?style=flat)
![badge-iosX64](https://img.shields.io/badge/platform-iosX64-CDCDCD?style=flat)
![badge-iosArm64](https://img.shields.io/badge/platform-iosArm64-CDCDCD?style=flat)
![badge-iosSimulatorArm64](https://img.shields.io/badge/platform-iosSimulatorArm64-CDCDCD?style=flat)

**TodoApp** is a sample Flutter project designed as a testing playground for experimenting with various features and implementations.

## How to run the project?

- Generate code:

```shell
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

- Run:

```shell
flutter run -d <device target>
```

## Tech Stack

### Data classes

- [Freezed](https://pub.dev/packages/freezed);

- [Freezed Annotations](https://pub.dev/packages/freezed_annotation).

### Dependency injection

- [get_it](https://pub.dev/packages/get_it);

- [injectable](https://pub.dev/packages/injectable).

### Database

- [sqflite](https://pub.dev/packages/sqflite).

### Navigation

- [AutoRoute](https://pub.dev/packages/auto_route)

## Screenshots

### Android version

![Android teaser](/img/android-teaser2.gif)

### iOS version

![iOS teaser](/img/ios-teaser.gif)]
