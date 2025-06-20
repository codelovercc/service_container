## 1.1.0

Breaking changes:

Make `ServiceContainerLogging` an extension on `ContainerConfigure`

Migrations:

- `ServiceContainerLogging.enableDebugLogPrinter` method to
  `containerConfigure.enableDebugLogPrinter`
- `ServiceContainerLogging.enableDebugLogging` method to `containerConfigure.enableDebugLogging`
- `ServiceContainerLogging.loggingEnabled` to `ContainerConfigure.loggingEnabled`
- `ServiceContainerLogging.onRecord` to `ContainerConfigure.onRecord`

## 1.0.12

- Add async descriptor types.
- Update async init service doc.

## 1.0.11

- Update service descriptor naming convention

## 1.0.10

- Update service descriptor naming convention

## 1.0.9

- Refactor Container Configuration with Extensions

## 1.0.8

- Downgrade meta dependency to 1.15.0

## 1.0.7

- Add service container configuration and override capability

## 1.0.6

- Streamline service descriptor constructors

## 1.0.5

- Enhance Service Descriptor with Specific Lifetime Descriptors

## 1.0.4

- Implement extension methods for IServiceProvider for retrieving multiple services by descriptors.

## 1.0.3

- Fix dart doc

## 1.0.2

- Refactor logging and improve debug logs

## 1.0.1

- Update example in README.md
- Export logging library

## 1.0.0

- Initial version.
