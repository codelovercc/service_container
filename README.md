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

```dart

import 'package:service_container/service_container.dart';

void main() {
  final provider = ServiceProvider();
  final scope = provider.createScope();
  final scope2 = provider.createScope();

  final singleton = scope.provider.getService(singletonService);
  final singleton2 = provider.getService(singletonService);
  assert(identical(singleton, singleton2));

  final scoped = scope.provider.getService(scopedService);
  final scoped2 = scope2.provider.getService(scopedService);
  assert(!identical(scoped, scoped2));

  final transient = scope.provider.getService(transientService);
  final transient2 = scope.provider.getService(transientService);
  assert(!identical(transient, transient2));

  final scopedDependency = scope.provider.getService(scopedDependencyService);
  final scopedDependency2 = scope.provider.getService(scopedDependencyService);
  assert(identical(scopedDependency, scopedDependency2));

  scope2.dispose();
  scope.disposeAsync();
  provider.dispose();
}

// define services

ServiceDescriptor<IMySingletonService> singletonService = ServiceDescriptor.singleton((p) =>
    MySingletonService());
ServiceDescriptor<IMyScopedService> scopedService = ServiceDescriptor.scoped((p) =>
    MyScopedService());
ServiceDescriptor<IMyTransientService> transientService = ServiceDescriptor.transient((p) =>
    MyTransientService());
ServiceDescriptor<MyScopedDependencyService> scopedDependencyService = ServiceDescriptor.scoped(
      (p) =>
      MyScopedDependencyService(
        singletonService: p.getService(singletonService),
        scopedService: p.getService(scopedService),
        transientService: p.getService(transientService),
      ),
);

abstract interface class IMySingletonService implements IDisposable {}

class MySingletonService implements IMySingletonService {
  MySingletonService() {
    print("MySingletonService $hashCode constructing");
  }

  @override
  void dispose() {
    print("MySingletonService $hashCode disposing");
  }
}

abstract interface class IMyScopedService implements IAsyncDisposable {}

class MyScopedService implements IMyScopedService {
  MyScopedService() {
    print("MyScopedService $hashCode constructing");
  }

  @override
  Future<void> disposeAsync() {
    print("MyScopedService $hashCode disposing asynchronous");
    return Future<void>.value();
  }
}

abstract interface class IMyTransientService implements IDisposable {}

class MyTransientService implements IMyTransientService {
  MyTransientService() {
    print("MyTransientService $hashCode constructing");
  }

  @override
  void dispose() {
    print("MyTransientService $hashCode disposing");
  }
}

class MyScopedDependencyService {
  final IMySingletonService singletonService;
  final IMyScopedService scopedService;
  final IMyTransientService transientService;

  MyScopedDependencyService(
      {required this.singletonService, required this.scopedService, required this.transientService}) {
    print("MyDependencyService $hashCode constructing with "
        "IMySingletonService ${singletonService.hashCode}, "
        "IMyScopedService ${scopedService.hashCode}, "
        "IMyTransientService ${transientService.hashCode}");
  }
}

```

## Service descriptor naming

When using the Service Descriptor to define a service, use the following naming conventions:

- Variable names start with `$` or `_$`, and `_$` is used for private variables.
- Variable names use the name of the service type

With this naming convention, it will be easier for you to use this rule to get the service instance
you need, the naming in the example code above is only a usage example, and in a formal project
please adhere to that naming convention.

Example：

```dart
// The service type is `LogPrinter` and the variable name is `$LogPrinter`.
ServiceDescriptor<LogPrinter> $LogPrinter = ServiceDescriptor.singleton((p) => ConsoleLogPrinter());
// The service type is `IMySingletonService` and the variable name is `_$IMySingletonService`, it's private.
ServiceDescriptor<IMySingletonService> _$IMySingletonService = ServiceDescriptor.singleton((p) =>
    MySingletonService());
```

## Logging

Use [logging](https://pub.dev/packages/logging) package to logging.  
***Logging only available in debug mode***  
Typically, use `ServiceProvider({bool printDebugLogs = false})` constructor and pass
`printDebugLogs: true` to enable logging.

If that can't fitted you, you can use `ServiceContainerLogging` class.  
Use `ServiceContainerLogging.enableDebugLogging()` to enable logging in debug mode.  
Use `ServiceContainerLogging.enableDebugLogPrinter(provider)` to print logs in debug mode.  
You can reset Top-level variable `$LogPrinter` that defines
in [services.dart](lib/src/services.dart) to custom your log printer,
always use `$LogPrinter` service as your log printer.

To configure service container logging use `ServiceContainerLogging` class.

## Override services

You can reset the value of a descriptor when you can access the variable of the
descriptor,
but please note, do overrides before using the services, typically, overrides applied before
`ServiceProvider` created.  
There's a `ContainerConfigure` class can doing this:

```dart

import 'package:service_container/service_container.dart';

SingletonDescriptor<String> $String = SingletonDescriptor((p) => "Hello World");

// Add your custom configuration as a extension method of ContainerConfigure
extension MyContainerConfigure on ContainerConfigure {
  void configureMyServices() {
    $String = SingletonDescriptor((p) => "Hi, World");
  }
}

void main() {
  // Configure the service container before using it
  containerConfigure.configureMyServices();
  final p = ServiceProvider();
  final s = p.getService($String);
  print(s);
}

```

In this way, you can configure the overridable service descriptors in different packages uniformly
to replace different service implementations, especially you have multi packages in your project.

## Additional information

In Flutter, you can
use [flutter_service_container](https://pub.dev/packages/flutter_service_container).
