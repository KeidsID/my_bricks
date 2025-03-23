import "dart:io";

import "package:mason/mason.dart";
import "package:hooks/hooks.dart";

Future<void> run(HookContext context) async {
  final configs = HookConfigs(context);
  final log = context.logger;

  final projectName = configs.projectName.value;
  final importAlias = configs.importAlias.value;
  final appName = configs.appName.value;

  await runSetup(context);

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

Future<void> runSetup(HookContext context) async {
  final log = context.logger;
  final configs = HookConfigs(context);

  final projectName = configs.projectName.value;

  final preSetupProgress = log.progress("Resolving dependencies...");

  Directory.current = "./$projectName";
  final preSetupResults = await Future.wait([
    Process.run("git", ["init", "-b=main"]),
    runFlutter(["pub", "get"]),
  ]);
  final isPreSetupSuccess = preSetupResults.every((e) => e.exitCode == 0);

  isPreSetupSuccess ? preSetupProgress.complete() : preSetupProgress.fail();

  final setupProgress = log.progress("Setup project...");

  final setupFutures = Future.wait([
    runDart(["run", "build_runner", "build", "-d"]),
    runDart(["run", "husky", "install"]),
  ]);
  List<String> setupFails = [];
  final isSetupSuccess =
      isPreSetupSuccess
          ? (await setupFutures).every((result) {
            final isSuccess = result.exitCode == 0;

            if (!isSuccess) {
              setupFails = [...setupFails, "${result.stdout}"];
            }

            return isSuccess;
          })
          : false;

  if (isSetupSuccess) {
    setupProgress.complete();
  } else {
    setupProgress.fail();
    log.info("");

    for (var msg in setupFails) {
      log.warn(msg);
    }
    log.warn("Fail to setup project.");
    log.info("Because it fails, follow the setup guide on README.md");
  }
}
