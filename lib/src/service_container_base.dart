import 'dart:async';

import 'package:logging/logging.dart';

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

/// A const instance of [ContainerConfigure]
const containerConfigure = ContainerConfigure._();

/// Service container configuration.
///
/// Provide a way to configure the service container,
/// e.g. by rewriting the value of the service descriptor in order to replace the implementation of the service.
///
/// Usage: <br/>
/// By adding extension methods on [ContainerConfigure], you can configure the overridable service descriptors in different packages uniformly,
/// then you can do this:
/// ```dart
/// SingletonDescriptor<String> $String = SingletonDescriptor((p) => "Hello World");
///
/// extension MyContainerConfigureExtension on ContainerConfigure {
/// void configureMyService() {
///     $String = SingletonDescriptor((p) => "Hi, World");
/// }
/// }
///
/// void main() {
///   // Configure the service container before using it
///   containerConfigure.configureMyService();
///   final p = ServiceProvider();
///   final s = p.getService($String);
///   print(s);
/// }
/// ```
/// In this way, you can configure the overridable service descriptors in different packages uniformly to replace different service implementations.
final class ContainerConfigure {
  const ContainerConfigure._();

  /// Whether logs for service containers are enabled.
  static bool get loggingEnabled => ServiceContainerLogging._enableLogging;

  /// Get the logger stream for service container. if [loggingEnabled] is `false`, it will return `null`.
  ///
  /// When [hierarchicalLoggingEnabled] is `ture`, the listeners will only receive logs from service container logger.
  /// When `false`, the listeners actually listen to [Logger.root] and will receive logs from all loggers.
  ///
  /// Regardless of whether [hierarchicalLoggingEnabled] is ture or not,
  /// the listeners of [Logger.root] will always receive logs from all loggers,
  /// unless the current listener is listening to a detached logger.
  static Stream<LogRecord>? get onRecord => ServiceContainerLogging._logger?.onRecord;
}
