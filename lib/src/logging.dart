import 'package:logging/logging.dart';

/// Console ansi color helper
class ConsoleColor {
  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const ansiEsc = '\x1B[';

  /// Reset all colors and options for current SGRs to terminal defaults.
  static const ansiDefault = '${ansiEsc}0m';

  /// The color
  ///
  /// Values: [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  final int? color;

  /// Construct from [color]
  ///
  /// - [color] The color, Values: [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  const ConsoleColor({this.color});

  /// None color
  const ConsoleColor.none() : this();

  /// Use grayscale levels to construct a gray
  ///
  /// - [level] Floating-point numbers from 0 to 1, 0 is black.
  ConsoleColor.grey({required double level})
      : this(
          color: 232 + (level.clamp(0.0, 1.0) * 23).round(),
        );

  /// To foreground console ansi color string.
  String toFgString() => hasColor ? '${ansiEsc}38;5;${color}m' : '';

  /// To background console ansi color string.
  String toBgString() => hasColor ? '${ansiEsc}48;5;${color}m' : '';

  /// Return a string with the foreground color.
  ///
  /// - [msg] The string to be colored.
  String fgMsg(String msg) => "${toFgString()}$msg${ConsoleColor.ansiDefault}";

  /// Return a string with the background color.
  ///
  /// - [msg] The string to be colored.
  String bgMsg(String msg) => "${toBgString()}$msg${ConsoleColor.ansiDefault}";
}

abstract class ConsoleColors {
  /// Black foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get black => ConsoleColor(color: 0);

  /// White foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get white => ConsoleColor(color: 231);

  /// Gray foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get gray => ConsoleColor.grey(level: .5);

  /// Light gray foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get lightGray => ConsoleColor(color: 252);

  /// Dark gray foreground color
  static ConsoleColor get darkGrey => ConsoleColor.grey(level: .25);

  /// Blue foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get blue => ConsoleColor(color: 21);

  /// Yellow foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get yellow => ConsoleColor(color: 226);

  /// Dark yellow foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get darkYellow => ConsoleColor(color: 58);

  /// Red foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get red => ConsoleColor(color: 196);

  /// Magenta foreground color
  ///
  /// [256 ANSI Color Codes](https://hexdocs.pm/color_palette/ansi_color_codes.html)
  static ConsoleColor get magenta => ConsoleColor(color: 201);
}

/// Provide additional methods
extension ConsoleColorExtensions on ConsoleColor {
  /// Check if there is any color.
  bool get hasColor => color != null;

  /// Use [fgColor] as the foreground color and the current color as background color.
  String withFgMsg(String msg, ConsoleColor fgColor) =>
      "${fgColor.toFgString()}${toBgString()}$msg${ConsoleColor.ansiDefault}";

  /// Use [bgColor] as the background color and the current color as foreground color.
  ///
  /// Return a string that is colored.
  String withBgMsg(String msg, ConsoleColor bgColor) =>
      "${toFgString()}${bgColor.toBgString()}$msg${ConsoleColor.ansiDefault}";
}

final Map<Level, String Function(String msg)> _levelMsgColors = {
  Level.FINEST: (msg) => msg,
  Level.FINER: (msg) => msg,
  Level.FINE: (msg) => msg,
  Level.CONFIG: (msg) => msg,
  Level.INFO: (msg) => msg,
  Level.WARNING: (msg) => ConsoleColors.darkYellow.fgMsg(msg),
  Level.SEVERE: (msg) => ConsoleColors.red.fgMsg(msg),
  Level.SHOUT: (msg) => ConsoleColors.magenta.fgMsg(msg),
};

final Map<Level, String Function(String msg)> _levelLabelColors = {
  Level.FINEST: (msg) => ConsoleColors.gray.withBgMsg(msg, ConsoleColors.black),
  Level.FINER: (msg) => ConsoleColors.lightGray.withBgMsg(msg, ConsoleColors.black),
  Level.FINE: (msg) => ConsoleColors.blue.withBgMsg(msg, ConsoleColors.lightGray),
  Level.CONFIG: (msg) => ConsoleColors.blue.withBgMsg(msg, ConsoleColors.lightGray),
  Level.INFO: (msg) => ConsoleColors.blue.withBgMsg(msg, ConsoleColors.lightGray),
  Level.WARNING: (msg) => ConsoleColors.yellow.withBgMsg(msg, ConsoleColors.black),
  Level.SEVERE: (msg) => ConsoleColors.black.withBgMsg(msg, ConsoleColors.red),
  Level.SHOUT: (msg) => ConsoleColors.white.withBgMsg(msg, ConsoleColors.magenta),
};

/// support to print logs that published by dart:logging package.
abstract interface class LogPrinter {
  /// Print logs that published by dart:logging package.
  void printLog(LogRecord record);
}

/// The default [LogPrinter] for console
class ConsoleLogPrinter implements LogPrinter {
  final bool _colored;

  /// Create printer.
  /// When [colored] is `true` (the default), the log messages will be print in color.
  ConsoleLogPrinter({bool colored = true}) : _colored = colored;
  @override
  void printLog(LogRecord record) {
    final labelColor = _colored ? _levelLabelColors[record.level] ?? (msg) => msg : (String msg) => msg;
    final msgColor = _colored ? _levelMsgColors[record.level] ?? (msg) => msg : (String msg) => msg;
    final writer = StringBuffer();
    writer.write(labelColor("[${record.level.name.toUpperCase()}]"));
    writer.writeln(" ${DateTime.now()} [${record.loggerName}]");
    writer.writeln(msgColor(record.message));
    if (record.error != null) {
      writer.writeln(msgColor(record.error.toString()));
    }
    if (record.stackTrace != null) {
      writer.writeln(msgColor(record.stackTrace.toString()));
    }
    print(writer.toString().trimRight());
  }
}
