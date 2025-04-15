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

class ServiceDescriptor<T> {
  final Type serviceType;
  final ServiceLifeTime lifeTime;
  late final ServiceFactory<T> factory;

  /// cache for per [ServiceDescriptor] instance.
  Map<_ServiceProviderScope, T>? _instances;

  /// Indicates that a singleton service instance is released by the container or the consumer.
  final bool? _autoDispose;

  ServiceDescriptor.singleton(this.factory)
      : lifeTime = ServiceLifeTime.singleton,
        serviceType = T,
        _autoDispose = true,
        _desc = "ServiceType: $T LifeTime: ${ServiceLifeTime.singleton.name}";
  ServiceDescriptor.singletonFrom(T instance)
      : lifeTime = ServiceLifeTime.singleton,
        serviceType = T,
        _autoDispose = false,
        _desc = "ServiceType: $T LifeTime: ${ServiceLifeTime.singleton.name}" {
    factory = (_) => instance;
  }
  ServiceDescriptor.scoped(this.factory)
      : lifeTime = ServiceLifeTime.scoped,
        serviceType = T,
        _autoDispose = null,
        _desc = "ServiceType: $T LifeTime: ${ServiceLifeTime.scoped.name}";
  ServiceDescriptor.transient(this.factory)
      : lifeTime = ServiceLifeTime.transient,
        serviceType = T,
        _autoDispose = null,
        _desc = "ServiceType: $T LifeTime: ${ServiceLifeTime.transient.name}";

  final String _desc;

  @override
  String toString() => _desc;
}
