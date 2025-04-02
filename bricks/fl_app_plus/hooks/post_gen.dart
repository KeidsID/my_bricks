import "dart:io";

import "package:mason/mason.dart";
import "package:hooks/hooks.dart";

Future<void> run(HookContext context) async {
  final configs = HookConfigs(context);

  final projectName = configs.projectName.value;

  Directory.current = "./$projectName";
  if (await runPreSetup(context)) await runSetup(context);
  await runPostSetup(context);
}

Future<bool> runPreSetup(HookContext context) async {
  final log = context.logger;
  final progress = log.progress("Resolving dependencies...");

  final results = await Future.wait([
    Process.run("git", ["init", "-b", "main"]),
    runFlutter(["pub", "get"]),
  ]);
  final isSuccess = results.every((e) => e.exitCode == 0);

  isSuccess ? progress.complete() : progress.fail();

  return isSuccess;
}

Future<bool> runSetup(HookContext context) async {
  final log = context.logger;

  final setupProgress = log.progress("Setup project...");

  final results = await Future.wait([
    runDart(["run", "build_runner", "build", "-d"]),
    runDart(["run", "husky", "install"]),
  ]);
  List<String> setupFails = [];
  final isSetupSuccess = results.every((result) {
    final isSuccess = result.exitCode == 0;

    if (!isSuccess) {
      setupFails = [...setupFails, "${result.stdout}"];
    }

    return isSuccess;
  });

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

  return isSetupSuccess;
}

Future<void> runPostSetup(HookContext context) async {
  final configs = HookConfigs(context);
  final log = context.logger;

  final projectName = configs.projectName.value;
  final importAlias = configs.importAlias.value;
  final appName = configs.appName.value;

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
    log.info('{ import "package:$importAlias/main.dart"; }');
  }
}
