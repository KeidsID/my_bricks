import "dart:io";

/// Run dart with fvm fallback.
Future<ProcessResult> runDart(List<String> args) async {
  final dartResult = await Process.run("dart", args);

  if (dartResult.exitCode == 0) return dartResult;

  return Process.run("fvm", ["dart", ...args]);
}

/// Run flutter with fvm fallback.
Future<ProcessResult> runFlutter(List<String> args) async {
  final flutterResult = await Process.run("flutter", args);

  if (flutterResult.exitCode == 0) return flutterResult;

  return Process.run("fvm", ["flutter", ...args]);
}
