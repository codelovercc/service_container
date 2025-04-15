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

ServiceDescriptor<IMySingletonService> singletonService = ServiceDescriptor.singleton((p) => MySingletonService());
ServiceDescriptor<IMyScopedService> scopedService = ServiceDescriptor.scoped((p) => MyScopedService());
ServiceDescriptor<IMyTransientService> transientService = ServiceDescriptor.transient((p) => MyTransientService());
ServiceDescriptor<MyScopedDependencyService> scopedDependencyService = ServiceDescriptor.scoped(
  (p) => MyScopedDependencyService(
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
