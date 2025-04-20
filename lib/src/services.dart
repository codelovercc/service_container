part of 'service_container_base.dart';

// define services that service container needs.

/// dart:logging package's log printer.
///
/// This service will be used by service container's logger, you can set a new printer to replace the default.
ServiceDescriptor<LogPrinter> $LogPrinter = ServiceDescriptor.singleton((p) => ConsoleLogPrinter());
