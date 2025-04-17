part of 'service_container_base.dart';

class _ServiceProviderScope implements IServiceScope, IServiceProvider {
  bool _disposed = false;
  final bool _isRoot;

  /// Root Service Provider
  late final _ServiceProviderScope _root;

  /// Contains the descriptors that created instances from this scope.
  List<ServiceDescriptor>? _services;

  static final Logger? _logger = ServiceContainerLogging._logger;

  _ServiceProviderScope({required _ServiceProviderScope root})
      : assert(root._isRoot, "Argument root is not a root scope."),
        _root = root,
        _isRoot = false {
    assert(() {
      _logger?.info("Service scope $hashCode constructing, root: $_isRoot");
      return true;
    }());
  }

  _ServiceProviderScope._root({bool printDebugLogs = false}) : _isRoot = true {
    _root = this;
    assert(() {
      if (printDebugLogs) {
        ServiceContainerLogging.enableDebugLogPrinter(this);
      }
      _logger?.info("Service scope $hashCode constructing, root: $_isRoot");
      return true;
    }());
  }

  @override
  IServiceScope createScope() {
    assert(!_disposed, "Scope has been disposed.");
    return _ServiceProviderScope(root: _root);
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    if (_services?.isNotEmpty == true) {
      for (final d in _services!) {
        assert(d.lifeTime != ServiceLifeTime.transient,
            "Cached service descriptors should never contains a transient descriptor and it's life-time is controlled by consumer.");
        final instances = d._instances;
        if (instances == null) {
          continue;
        }
        final instance = instances.remove(this);
        if (instances.isEmpty) {
          d._instances = null;
        }
        if (instance is IDisposable) {
          instance.dispose();
        } else if (instance is IAsyncDisposable) {
          instance.disposeAsync();
        }
      }
    }
    _services = null;
    assert(() {
      _logger?.info("Service scope $hashCode disposed, root: $_isRoot");
      return true;
    }());
  }

  @override
  Future<void> disposeAsync() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    if (_services?.isNotEmpty == true) {
      for (final d in _services!) {
        assert(d.lifeTime != ServiceLifeTime.transient,
            "Cached service descriptors should never contains a transient descriptor and it's life-time is controlled by consumer.");
        final instances = d._instances;
        if (instances == null) {
          continue;
        }
        final instance = instances.remove(this);
        if (instances.isEmpty) {
          d._instances = null;
        }
        if (instance is IDisposable) {
          instance.dispose();
        } else if (instance is IAsyncDisposable) {
          await instance.disposeAsync();
        }
      }
    }
    _services = null;
    assert(() {
      _logger?.info("Service scope $hashCode disposed, root: $_isRoot");
      return true;
    }());
  }

  T _createCachedService<T>(ServiceDescriptor<T> descriptor) {
    final autoDispose = descriptor._autoDispose == null || descriptor._autoDispose;
    if (autoDispose) {
      final cached = descriptor._instances?[this];
      if (cached != null) {
        assert(() {
          _logger?.info("Fetched, $descriptor");
          return true;
        }());
        return cached;
      }
      final service = _createService(descriptor);
      descriptor._createInstanceMap();
      descriptor._instances![this] = service;
      if (service is IDisposable || service is IAsyncDisposable) {
        _services ??= [];
        _services!.add(descriptor);
      }
      return service;
    }
    return _createService(descriptor);
  }

  T _createService<T>(ServiceDescriptor<T> descriptor) {
    assert(() {
      if (descriptor._autoDispose == false) {
        _logger?.info("Fetching, $descriptor");
      } else {
        _logger?.info("Creating, $descriptor");
      }
      return true;
    }());
    return descriptor.factory(this);
  }

  @override
  T getService<T>(ServiceDescriptor<T> descriptor) {
    assert(!_disposed, "Scope has been disposed.");
    switch (descriptor.lifeTime) {
      case ServiceLifeTime.singleton:
        return _isRoot ? _createCachedService(descriptor) : _root._createCachedService(descriptor);
      case ServiceLifeTime.scoped:
        assert(!_isRoot, "Scoped service can not provide by root. $descriptor");
        return _createCachedService(descriptor);
      case ServiceLifeTime.transient:
        return _createService(descriptor);
    }
  }

  @override
  IServiceProvider get provider {
    assert(!_disposed, "Scope has been disposed.");
    return this;
  }
}

/// Represents the root service provider, it's a [IServiceScopeFactory] too.
final class ServiceProvider implements IServiceProvider, IDisposable, IAsyncDisposable {
  final _ServiceProviderScope _root;

  /// Root service provider
  ///
  /// - [printDebugLogs] When `ture` print debug logs in debug-mode.
  /// if you only want to enable service container debug logging please call [ServiceContainerLogging.enableDebugLogging]
  /// before service container is created and set this argument to `false`.
  /// To prevent duplicate log outputs, see [ServiceContainerLogging]
  ServiceProvider({bool printDebugLogs = false}) : _root = _ServiceProviderScope._root(printDebugLogs: printDebugLogs);

  @override
  void dispose() => _root.dispose();

  @override
  Future<void> disposeAsync() async => await _root.disposeAsync();

  @override
  T getService<T>(ServiceDescriptor<T> descriptor) => _root.getService(descriptor);

  @override
  IServiceScope createScope() => _root.createScope();
}
