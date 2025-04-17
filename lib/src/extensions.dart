part of 'service_container_base.dart';

/// Extension methods for [IServiceProvider]
extension ServiceProviderExtensions on IServiceProvider {
  /// Get a service iterable by [descriptors]
  ///
  /// Returns an iterable of the service instances.
  Iterable<Object> getServices(Iterable<ServiceDescriptor> descriptors) sync* {
    for (final d in descriptors) {
      yield (getService(d) as Object);
    }
  }

  /// Get a service iterable by [descriptors]
  ///
  /// - [T] The type of the service
  /// - [descriptors] The service descriptors
  ///
  /// Returns an iterable of the service instances of type [T].
  Iterable<T> getServicesOfType<T>(Iterable<ServiceDescriptor<T>> descriptors) sync* {
    for (final d in descriptors) {
      yield getService(d);
    }
  }
}
