part of 'service_container_base.dart';

// define services that service container needs.

/// dart:logging package's log printer.
///
/// This service will be used by service container's logger, you can set a new printer to replace the default.
ServiceDescriptor<LogPrinter> $logPrinter = ServiceDescriptor.singleton((p) => ConsoleLogPrinter());

StreamSubscription<LogRecord>? _subscription;

final ServiceDescriptor<Logger> _$serviceContainerLogger = ServiceDescriptor.singleton((p) {
  final l = Logger("$ServiceProvider");
  final printer = p.getService($logPrinter);
  if (!hierarchicalLoggingEnabled && _subscription == null) {
    _subscription = l.onRecord.listen(printer.printLog);
  }
  return l;
});
