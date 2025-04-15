<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# service_container

[![pub package](https://img.shields.io/pub/v/service_container?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/service_container)
[![CI](https://img.shields.io/github/actions/workflow/status/codelovercc/service_container/dart.yml?branch=main&logo=github-actions&logoColor=white)](https://github.com/codelovercc/service_container/actions)
[![Last Commits](https://img.shields.io/github/last-commit/codelovercc/service_container?logo=git&logoColor=white)](https://github.com/codelovercc/service_container/commits/main)
[![Pull Requests](https://img.shields.io/github/issues-pr/codelovercc/service_container?logo=github&logoColor=white)](https://github.com/codelovercc/service_container/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/codelovercc/service_container?logo=github&logoColor=white)](https://github.com/codelovercc/service_container)
[![License](https://img.shields.io/github/license/codelovercc/service_container?logo=open-source-initiative&logoColor=green)](https://github.com/codelovercc/service_container/blob/main/LICENSE)

A services container, fast and easy to use.

## Features

Provide services life time control with singleton, scoped, transient.

## Getting started

With Dart:

```shell
dart pub add service_container
```

With Flutter:

```shell
flutter pub add service_container
```

## Usage

Please goto [service_container_example](example/service_container_example.dart)

## Logging

Use [logging](https://pub.dev/packages/logging) package to logging.
You can reset Top-level variable `$logPrinter` that defines in [services.dart](lib/src/services.dart) to custom your log printer.

## Additional information

In Flutter, you can use [flutter_service_container](https://pub.dev/packages/flutter_service_container).Ò
