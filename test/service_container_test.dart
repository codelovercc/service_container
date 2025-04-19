import 'package:service_container/service_container.dart';
import 'package:test/test.dart';

void main() {
  group("Service container", () {
    late ServiceProvider provider;
    setUpAll(() {
      // Configure the service container before using it
      containerConfigure.configureMyServices();
    });
    setUp(() {
      return provider = ServiceProvider(printDebugLogs: true);
    });
    tearDown(() {
      provider.dispose();
    });
    test("Singleton service should be the same in different scope", () {
      final singleton = provider.getService(mySingletonService);
      final scope = provider.createScope();
      final singletonInScope = scope.provider.getService(mySingletonService);
      expect(singletonInScope, same(singleton));
      final scope2 = scope.provider.createScope();
      final singletonInScope2 = scope2.provider.getService(mySingletonService);
      expect(singletonInScope, same(singletonInScope2));
      // instanced singleton
      final s = provider.getService(mySingletonServiceInstanced);
      final s1 = scope.provider.getService(mySingletonServiceInstanced);
      final s2 = scope2.provider.getService(mySingletonServiceInstanced);
      expect(s, same(s1));
      expect(s2, same(s1));
      scope.dispose();
      scope2.dispose();
    });
    test("Instanced singleton service should not dispose when provider is disposed", () {
      final p = ServiceProvider();
      final s = p.getService(mySingletonServiceInstanced);
      p.dispose();
      expect((s as MySingletonServiceInstanced).disposed, isFalse);
      s.dispose();
      expect(s.disposed, isTrue);
    });
    test("Scoped service should error when provide it from root", () {
      expect(() => provider.getService(myScopedService), throwsA(isA<AssertionError>()));
    });
    test("Transient service should not be the same", () {
      final scope = provider.createScope();
      final scope1 = scope.provider.createScope();
      final list = [
        provider.getService(myTransientService),
        provider.getService(myTransientService),
        provider.getService(myTransientService),
        scope.provider.getService(myTransientService),
        scope.provider.getService(myTransientService),
        scope.provider.getService(myTransientService),
        scope1.provider.getService(myTransientService),
        scope1.provider.getService(myTransientService),
        scope1.provider.getService(myTransientService),
      ];
      final set = list.toSet();
      expect(set.length, equals(list.length));
      for (final s in set) {
        s.dispose();
      }
      scope1.dispose();
      scope.dispose();
    });
    test("Service that depend other service should provide correctly", () {
      final scope = provider.createScope();
      final s = scope.provider.getService(myScopedDependencyService);
      expect(s.scopedService, isA<IMyScopedService>());
      scope.dispose();
    });
    test("Singleton service that depend scoped service should cause error", () {
      final scope = provider.createScope();
      expect(() => scope.provider.getService(myInvalidDependencySingletonService), throwsA(isA<AssertionError>()));
      scope.dispose();
    });
    test("Singleton service should be disposed when root provider is disposed", () async {
      final p = ServiceProvider();
      final s = p.getService(mySingletonService1);
      await p.disposeAsync();
      expect(s.disposed, isTrue);
    });
    test("Scoped service should dispose correctly", () {
      final scope = provider.createScope();
      final s = scope.provider.getService(myScopedDisposableService);
      scope.dispose();
      expect(s.disposed, isTrue);
    });
    test("AsyncDisposable service should work in synchronous method", () {
      final scope = provider.createScope();
      final s = scope.provider.getService(myScopedAsyncDisposableService);
      scope.dispose();
      expect(s.disposed, isTrue);
    });
    test("Scoped service should dispose asynchronously correctly", () async {
      final scope = provider.createScope();
      final s = scope.provider.getService(myScopedDisposableService);
      await scope.disposeAsync();
      expect(s.disposed, isTrue);
    });
    test("Should throw error when scope has been disposed", () {
      final scope = provider.createScope();
      final p = scope.provider;
      scope.dispose();
      expect(() => scope.provider, throwsA(isA<AssertionError>()));
      expect(() => scope.provider.createScope(), throwsA(isA<AssertionError>()));
      expect(() => p.createScope(), throwsA(isA<AssertionError>()));
      expect(() => p.getService(myScopedService), throwsA(isA<AssertionError>()));
    });
    test("Same type but different descriptors should create different service instances", () {
      final scope = provider.createScope();
      final s = scope.provider.getService(myScopedService);
      final s1 = scope.provider.getService(myScopedService1);
      scope.dispose();
      expect(s, isNot(same(s1)));
    });
    test("Scoped service should be the same", () {
      final scope = provider.createScope();
      final s = scope.provider.getService(myScopedService);
      final s1 = scope.provider.getService(myScopedService);
      scope.dispose();
      expect(s, same(s1));
    });
    test("getServices extension method should work", () {
      final scope = provider.createScope();
      final services = scope.provider.getServices(iterableDynamicServices);
      expect(services.length, equals(iterableDynamicServices.length));
      scope.dispose();
    });
    test("getServicesOfType extension method should work", () {
      final scope = provider.createScope();
      final services = scope.provider.getServicesOfType<IterableService>(iterableServices);
      expect(services.length, equals(iterableServices.length));
      scope.dispose();
    });
    test("Fixed service type definition should work", () {
      final scope1 = provider.createScope();
      final scope2 = provider.createScope();
      final singleton1 = scope1.provider.getService(fixedTypeSingleton);
      final singleton2 = scope2.provider.getService(fixedTypeSingleton);
      final singleton1Instanced = scope1.provider.getService(fixedTypeSingleton1);
      final singleton2Instanced = scope2.provider.getService(fixedTypeSingleton1);
      final scoped1 = scope1.provider.getService(fixedTypeScoped);
      final scoped2 = scope2.provider.getService(fixedTypeScoped);
      final transient1 = scope1.provider.getService(fixedTypeTransient);
      final transient2 = scope2.provider.getService(fixedTypeTransient);
      scope1.dispose();
      scope2.dispose();
      expect(singleton1, same(singleton2));
      expect(singleton1Instanced, same(singleton2Instanced));
      expect(scoped1, isNot(same(scoped2)));
      expect(transient1, isNot(same(transient2)));
    });
    test("ContainerConfigure should work", () {
      final str = provider.getService(mySingletonString);
      expect(str, equals("Hi, World"));
    });
  });
}

ServiceDescriptor<IMySingletonService> mySingletonService = ServiceDescriptor.singleton((p) => MySingletonService());
ServiceDescriptor<IMySingletonService> mySingletonServiceInstanced =
    ServiceDescriptor.singletonFrom(MySingletonServiceInstanced());
ServiceDescriptor<IMySingletonService1> mySingletonService1 = ServiceDescriptor.singleton((p) => MySingletonService1());
ServiceDescriptor<IMyScopedService> myScopedService = ServiceDescriptor.scoped((p) => MyScopedService());
ServiceDescriptor<IMyScopedService> myScopedService1 = ServiceDescriptor.scoped((p) => MyScopedService());
ServiceDescriptor<IMyTransientService> myTransientService = ServiceDescriptor.transient((p) => MyTransientService());
ServiceDescriptor<MyScopedDependencyService> myScopedDependencyService = ServiceDescriptor.scoped(
  (p) => MyScopedDependencyService(
    singletonService: p.getService(mySingletonService),
    scopedService: p.getService(myScopedService),
    transientService: p.getService(myTransientService),
  ),
);
ServiceDescriptor<MyInvalidScopedDependencySingletonService> myInvalidDependencySingletonService =
    ServiceDescriptor.singleton(
  (p) => MyInvalidScopedDependencySingletonService(
    scopedService: p.getService(myScopedService),
  ),
);
ServiceDescriptor<MyScopedDisposableService> myScopedDisposableService =
    ServiceDescriptor.scoped((p) => MyScopedDisposableService());
ServiceDescriptor<MyScopedAsyncDisposableService> myScopedAsyncDisposableService =
    ServiceDescriptor.scoped((p) => MyScopedAsyncDisposableService());

List<ServiceDescriptor<IterableService>> iterableServices = [
  ServiceDescriptor.singleton((p) => IterableService1()),
  ServiceDescriptor.singleton((p) => IterableService2()),
  ServiceDescriptor.singleton((p) => IterableService3()),
  ServiceDescriptor.singleton((p) => IterableService4()),
];

List<ServiceDescriptor> iterableDynamicServices = [
  mySingletonService,
  myScopedService,
  myTransientService,
];

SingletonDescriptor<IMySingletonService> fixedTypeSingleton = SingletonDescriptor((p) => MySingletonService());
SingletonDescriptor<IMySingletonService> fixedTypeSingleton1 = SingletonDescriptor.from(MySingletonServiceInstanced());
ScopedDescriptor<IMyScopedService> fixedTypeScoped = ScopedDescriptor((p) => MyScopedService());
TransientDescriptor<IMyTransientService> fixedTypeTransient = TransientDescriptor((p) => MyTransientService());

SingletonDescriptor<String> mySingletonString = SingletonDescriptor((p) => "Hello World");

extension MyContainerConfigure on ContainerConfigure {
  void configureMyServices() {
    mySingletonString = SingletonDescriptor((p) => "Hi, World");
  }
}

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

class MySingletonServiceInstanced implements IMySingletonService {
  bool disposed = false;
  MySingletonServiceInstanced() {
    print("MySingletonServiceInstanced $hashCode constructing");
  }

  @override
  void dispose() {
    print("MySingletonServiceInstanced $hashCode disposing");
    disposed = true;
  }
}

abstract interface class IMySingletonService1 implements IAsyncDisposable {
  bool disposed = false;
}

class MySingletonService1 implements IMySingletonService1 {
  MySingletonService1() {
    print("MySingletonService1 $hashCode constructing");
  }

  @override
  Future<void> disposeAsync() {
    disposed = true;
    print("MySingletonService1 $hashCode disposing asynchronous");
    return Future<void>.value();
  }

  @override
  bool disposed = false;
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

class MyScopedService1 implements IMyScopedService {
  MyScopedService1() {
    print("MyScopedService1 $hashCode constructing");
  }

  @override
  Future<void> disposeAsync() {
    print("MyScopedService1 $hashCode disposing asynchronous");
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

/// 用于测试作用域服务依赖了单例服务、其它作用域服务和瞬时服务
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

/// 用于测试单例服务依赖了作用域服务，在从服务容器中获取时，这会抛出非法作用域异常
class MyInvalidScopedDependencySingletonService {
  final IMyScopedService scopedService;

  MyInvalidScopedDependencySingletonService({required this.scopedService}) {
    print("MyInvalidScopedDependencyService should never instanced by IServiceProvider");
  }
}

class MyScopedAsyncDisposableService implements IAsyncDisposable {
  bool disposed = false;
  MyScopedAsyncDisposableService() {
    print("MyScopedAsyncDisposableService $hashCode constructing");
  }

  @override
  Future<void> disposeAsync() {
    print("MyScopedAsyncDisposableService $hashCode disposing asynchronous");
    disposed = true;
    return Future<void>.value();
  }
}

/// 用于测试同时实现了[IDisposable]和[IAsyncDisposable]的服务释放
class MyScopedDisposableService implements IDisposable, IAsyncDisposable {
  bool disposed = false;

  MyScopedDisposableService() {
    print("MyScopedDisposableService $hashCode constructing");
  }

  @override
  void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    print("MyScopedDisposableService $hashCode disposing");
  }

  @override
  Future<void> disposeAsync() {
    if (disposed) {
      return Future<void>.value();
    }
    disposed = true;
    print("MyScopedDisposableService $hashCode disposing asynchronous");
    return Future<void>.value();
  }
}

abstract class IterableService {}

class IterableService1 extends IterableService {}

class IterableService2 extends IterableService {}

class IterableService3 extends IterableService {}

class IterableService4 extends IterableService {}
