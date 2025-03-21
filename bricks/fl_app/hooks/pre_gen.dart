import "package:mason/mason.dart";
import "package:hooks/hooks.dart";

void run(HookContext context) {
  final configs = HookConfigs(context);

  final List<HookConfigsGetter> vars = [
    configs.projectName,
    configs.desc,
    configs.org,
    configs.appName,
    configs.importAlias,
  ];

  context.vars = vars.asMap().map((i, v) => MapEntry(v.key, v.value));
}
