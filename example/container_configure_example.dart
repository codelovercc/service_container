import 'package:meta/meta.dart';
import 'package:service_container/service_container.dart';

SingletonDescriptor<String> mySingletonString = SingletonDescriptor((p) => "Hello World");

class MyContainerConfigure extends ContainerConfigure {
  @mustCallSuper
  @override
  void configure() {
    super.configure();
    mySingletonString = SingletonDescriptor((p) => "Hi, World");
  }
}

void main() {
  // Configure the service container before using it
  MyContainerConfigure().configure();
  final p = ServiceProvider();
  final s = p.getService(mySingletonString);
  print(s);
}
