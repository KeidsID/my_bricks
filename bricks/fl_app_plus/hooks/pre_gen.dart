import "package:mason/mason.dart";
import "package:hooks/hooks.dart";

void run(HookContext context) {
  final configs = HookConfigs(context);

  context.vars = configs.getters.asMap().map(
    (_, getter) => MapEntry(getter.key, getter.value),
  );
}
