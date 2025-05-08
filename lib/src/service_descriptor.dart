part of 'service_container_base.dart';

/// Service factory.
///
/// [T] is the service type.
///
/// Returns an instance of type [T], and the factory method receives an [IServiceProvider] as a parameter.
///
/// If the service is [ServiceLifeTime.singleton], then [IServiceProvider] is the root service provider;
/// If the service is [ServiceLifeTime.scoped], then [IServiceProvider] is the service provider of the corresponding scope;
/// If the service is [ServiceLifeTime.transient], then [IServiceProvider] is the service provider of the corresponding scope;
typedef ServiceFactory<T> = T Function(IServiceProvider p);

// String _createStringFactory(IServiceProvider p) => "";
//
// const ServiceFactory<String> f = _createStringFactory;
// late is unnecessary, Top-level variables and static fields are implicitly late, so they don't need to be explicitly marked.
// late SingletonDescriptor<String> _myStringSingleton = SingletonDescriptor(factory: f);

/// Describe a service
class ServiceDescriptor<T> {
  /// The type of the service
  final Type serviceType;

  /// The life-time of the service
  final ServiceLifeTime lifeTime;

  /// The factory method of the service
  late final ServiceFactory<T> factory;

  /// cache for per [ServiceDescriptor] instance.
  Map<_ServiceProviderScope, T>? _instances;

  /// Create instance map if it's null.
  ///
  /// This method will work if [T] is `dynamic`, because [T] is settled while creating [ServiceDescriptor].
  /// In same cases, etc: `ServiceDescriptor<String>` will change to `ServiceDescriptor<dynamic>`,
  /// if you create a Map and assign it to [ServiceDescriptor] variable, it will not work, it will throw type error
  /// 'Type _Map<_ServiceProviderScope, dynamic> is not a subtype of type _Map<_ServiceProviderScope, T>',
  /// but this method is an instance method, the [T] is deterministic when the [ServiceDescriptor] is created, so the following code works.
  void _createInstanceMap() => _instances ??= {};

  /// Indicates that a singleton service instance is released by the container or the consumer.
  ///
  /// When `true` released by the container.
  /// When `false` released by the consumer.
  /// When `null`, it's not a singleton service.
  final bool? _autoDispose;

  /// Singleton descriptor
  ///
  /// Use [SingletonDescriptor] for service definition if you don't want someone rewrite your service to another life-time service.
  ServiceDescriptor.singleton(this.factory)
      : lifeTime = ServiceLifeTime.singleton,
        serviceType = T,
        _autoDispose = true;

  /// Singleton descriptor
  ///
  /// Use [SingletonDescriptor] for service definition if you don't want someone rewrite your service to another life-time service.
  ServiceDescriptor.singletonFrom(T instance)
      : lifeTime = ServiceLifeTime.singleton,
        serviceType = T,
        _autoDispose = false {
    factory = (_) => instance;
  }

  /// Scoped descriptor
  ///
  /// Use [ScopedDescriptor] for service definition if you don't want someone rewrite your service to another life-time service.
  ServiceDescriptor.scoped(this.factory)
      : lifeTime = ServiceLifeTime.scoped,
        serviceType = T,
        _autoDispose = null;

  /// Transient descriptor
  ///
  /// Use [TransientDescriptor] for service definition if you don't want someone rewrite your service to another life-time service.
  ServiceDescriptor.transient(this.factory)
      : lifeTime = ServiceLifeTime.transient,
        serviceType = T,
        _autoDispose = null;

  @override
  String toString() => "Descriptor: $hashCode ServiceType: $T LifeTime: ${lifeTime.name}";
}

/// Singleton descriptor
///
/// Use this type for service definition if you don't want someone rewrite your service to another life-time service.
///
/// Example:
/// ```dart
/// SingletonDescriptor<String> mySingletonService = SingletonDescriptor<String>(factory: _createStringFactory);
/// ```
class SingletonDescriptor<T> extends ServiceDescriptor<T> {
  SingletonDescriptor(super.factory) : super.singleton();

  SingletonDescriptor.from(super.instance) : super.singletonFrom();
}

/// Scoped descriptor
///
/// Use this type for service definition if you don't want someone rewrite your service to another life-time service.
///
/// Example:
/// ```dart
/// ScopedDescriptor<String> myScopedService = ScopedDescriptor<String>(factory: _createStringFactory);
/// ```
class ScopedDescriptor<T> extends ServiceDescriptor<T> {
  ScopedDescriptor(super.factory) : super.scoped();
}

/// Transient descriptor
///
/// Use this type for service definition if you don't want someone rewrite your service to another life-time service.
///
/// Example:
/// ```dart
/// TransientDescriptor<String> myTransientService = TransientDescriptor<String>(factory: _createStringFactory);
/// ```
class TransientDescriptor<T> extends ServiceDescriptor<T> {
  TransientDescriptor(super.factory) : super.transient();
}

/// Singleton future descriptor that supports asynchronous initialization.
class SingletonFutureDescriptor<T> extends SingletonDescriptor<Future<T>> {
  SingletonFutureDescriptor(super.factory);

  SingletonFutureDescriptor.from(super.instance);
}

/// Scoped future descriptor that supports asynchronous initialization.
class ScopedFutureDescriptor<T> extends ScopedDescriptor<Future<T>> {
  ScopedFutureDescriptor(super.factory);
}

/// Transient future descriptor that supports asynchronous initialization.
class TransientFutureDescriptor<T> extends TransientDescriptor<Future<T>> {
  TransientFutureDescriptor(super.factory);
}
