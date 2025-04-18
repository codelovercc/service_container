import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

part 'extensions.dart';
part 'implements.dart';
part 'logging.dart';
part 'service_descriptor.dart';
part 'services.dart';

/// Service life-time
enum ServiceLifeTime {
  /// Singleton, where only one instance exists in the same root service container.
  ///
  /// Singleton services are released by service containers if they are created by service containers, otherwise you have to release it.
  singleton,

  /// Scoped, the instances are not the same in different scoped service containers
  ///
  /// Scoped services are released by service containers.
  /// Different instances will be created in different scopes, and in the root service container,
  /// requests to scoped services are not allowed, and an assert error will be thrown in development mode.
  scoped,

  /// Transient, a new instance is created with each request.
  ///
  /// Each time an transient service is requested, a new instance is created.
  /// Transient services are not released by service containers, but are released by their consumers after they are obtained from service containers.
  transient,
}

/// Indicates the interface for which resources need to be released.
abstract interface class IDisposable {
  /// Release resources that need to be released.
  ///
  /// Note: Make sure that no exceptions are thrown when releasing resources
  void dispose();
}

/// Used to release resources asynchronously.
abstract interface class IAsyncDisposable {
  /// Asynchronously release resources that need to be released.
  ///
  /// Note: Make sure that no exceptions are thrown when releasing resources
  Future<void> disposeAsync();
}

/// Service provider interface
abstract interface class IServiceProvider implements IServiceScopeFactory {
  /// Use [descriptor] to fetch or create a service instance.
  T getService<T>(ServiceDescriptor<T> descriptor);
}

/// Service scope
abstract interface class IServiceScope implements IDisposable, IAsyncDisposable {
  /// Gets the service provider associated with that scope
  IServiceProvider get provider;
}

/// Service Scope Factory
abstract interface class IServiceScopeFactory {
  /// Create a scope
  IServiceScope createScope();
}

/// Service container configuration.
///
/// Provide a way to configure the service container,
/// e.g. by rewriting the value of the service descriptor in order to replace the implementation of the service.
///
/// Usage: <br/>
/// Extends this class and override the [configure] method.
/// Let us say you have a custom subclass of [ContainerConfigure] named `MyContainerConfigure`, then you can do this:
/// ```dart
/// SingletonDescriptor<String> mySingletonString = SingletonDescriptor((p) => "Hello World");
///
/// class MyContainerConfigure extends ContainerConfigure {
///   @mustCallSuper
///   @override
///   void configure() {
///     super.configure();
///     mySingletonString = SingletonDescriptor((p) => "Hi, World");
///   }
/// }
///
/// void main() {
///   // Configure the service container before using it
///   MyContainerConfigure().configure();
///   final p = ServiceProvider();
///   final s = p.getService(mySingletonString);
///   print(s);
/// }
/// ```
/// In this way, you can configure the overridable service descriptors in different packages uniformly to replace different service implementations.
class ContainerConfigure {
  /// Override this method to reconfigure the service descriptor in this method,
  /// e.g. by rewriting the value of the service descriptor in order to replace the implementation of the service.
  ///
  /// The default implementation does nothing.
  @mustCallSuper
  @mustBeOverridden
  void configure() {}
}
