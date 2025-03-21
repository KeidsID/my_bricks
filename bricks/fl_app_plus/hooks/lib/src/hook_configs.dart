import "package:mason/mason.dart";

typedef HookConfigsGetter<T> = ({String key, T value});

enum BrickVars {
  projectName._("project-name"),
  desc._("desc"),
  org._("org"),
  appName._("app-name"),
  importAlias._("import-alias");

  const BrickVars._(this.key);

  /// Key used on `brick.yaml`
  final String key;
}

/// {@template fla.hooks.HookConfigs}
/// Configs that handle brick vars.
///
/// Every vars getters will return key-value pair in record.
/// {@endtemplate}
class HookConfigs {
  final HookContext context;

  /// {@macro fla.hooks.HookConfigs}
  const HookConfigs(this.context);

  Map<String, dynamic> get _vars => context.vars;

  HookConfigsGetter<String> get projectName {
    final key = BrickVars.projectName.key;
    final value = (_vars[key] as String).snakeCase;

    return (key: key, value: value);
  }

  HookConfigsGetter<String> get desc {
    final key = BrickVars.desc.key;
    final value = _vars[key] as String;

    return (key: key, value: value);
  }

  HookConfigsGetter<String> get org {
    final key = BrickVars.org.key;
    final value = (_vars[key] as String).dotCase;

    return (key: key, value: value);
  }

  HookConfigsGetter<AppName> get appName {
    final key = BrickVars.appName.key;
    final raw = _vars[key];
    String value = projectName.value;

    if (raw is String && raw.isNotEmpty) value = raw;

    return (key: key, value: AppName(value));
  }

  HookConfigsGetter<ImportAlias> get importAlias {
    final key = BrickVars.importAlias.key;
    final raw = _vars[key];
    String value = projectName.value;

    if (raw is String && raw.isNotEmpty) value = raw;

    return (key: key, value: ImportAlias(value.snakeCase));
  }
}

extension type AppName(String value) {
  /// {@macro fla.hooks.checkIfProvided}
  bool checkIfProvided(HookConfigs configs) {
    return this as String != configs.projectName.value;
  }
}

extension type ImportAlias(String value) {
  /// {@template fla.hooks.checkIfProvided}
  /// Check if the value is provided in mason prompt.
  /// {@endtemplate}
  bool checkIfProvided(HookConfigs configs) {
    return this as String != configs.projectName.value;
  }
}
