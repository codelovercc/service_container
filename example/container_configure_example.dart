import 'package:service_container/service_container.dart';

SingletonDescriptor<String> $String = SingletonDescriptor((p) => "Hello World");

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
