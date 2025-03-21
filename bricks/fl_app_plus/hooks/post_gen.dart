import "package:mason/mason.dart";
import "package:hooks/hooks.dart";

void run(HookContext context) {
  final configs = HookConfigs(context);
  final log = context.logger;

  final projectName = configs.projectName.value;
  final importAlias = configs.importAlias.value;
  final appName = configs.appName.value;

  log.success("All done!");
  log.info(
    '"$projectName"'
    "${appName.checkIfProvided(configs) ? " ($appName)" : ""} "
    "created.",
  );
  log.info(
    "Don't forget to run the “flutter pub get” command before running "
    "your project.",
  );
  if (importAlias.checkIfProvided(configs)) {
    log.info("");
    log.info("Please remember your package import");
    log.info('(import "package:$importAlias/main.dart";)');
  }
}
