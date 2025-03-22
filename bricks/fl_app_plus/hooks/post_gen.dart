import "dart:io";

import "package:mason/mason.dart";
import "package:hooks/hooks.dart";

Future<void> run(HookContext context) async {
  final configs = HookConfigs(context);
  final log = context.logger;

  final projectName = configs.projectName.value;
  final importAlias = configs.importAlias.value;
  final appName = configs.appName.value;

  final progress = log.progress("Setup project...");

  Directory.current = "./$projectName";
  final setupResults = await Future.wait([
    runFlutter(["pub", "get"]),
    runDart(["run", "husky", "install"]),
    runDart(["run", "build_runner", "-d"]),
  ]);
  final isSetupSuccess = setupResults.every((e) => e.exitCode == 0);

  if (isSetupSuccess) {
    progress.complete();
  } else {
    progress.fail();
    log.info("");
    log.warn("Fail to setup project.");
    log.info("Because it fails, follow the setup guide on README.md");
  }

  log.info("");
  log.success("And that's it!");

  log.info(
    '"$projectName"'
    "${appName.checkIfProvided(configs) ? " ($appName)" : ""} "
    "created.",
  );

  if (importAlias.checkIfProvided(configs)) {
    log.info("");
    log.info("Please remember your package import");
    log.info('(import "package:$importAlias/main.dart";)');
  }
}

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
