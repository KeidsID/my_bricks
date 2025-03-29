import "package:mason/mason.dart";

import "hardcoded_workflows.dart" as workflows;

typedef HookConfigsGetter<T> = ({String key, T value});

enum BrickVars {
  projectName._("project-name"),
  desc._("desc"),
  org._("org"),
  appName._("app-name"),
  importAlias._("import-alias"),
  gitlintScopes._("gitlint-scopes"),
  gitlintRefPrefix._("gitlint-ref-prefix");

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

  /// Return every vars getters.
  List<HookConfigsGetter> get getters => [
    projectName,
    desc,
    org,
    appName,
    importAlias,
    gitlintScopes,
    hasGitlintScopes,
    gitlintRefPrefix,
    hasGitlintRefPrefix,
    cdWorkflow,
    ciPrWorkflow,
    ciWorkflow
  ];

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

  HookConfigsGetter<List> get gitlintScopes {
    final key = BrickVars.gitlintScopes.key;
    final raw = _vars[key];

    if (raw is List) return (key: key, value: raw);

    return (key: key, value: []);
  }

  /// Indicate that [gitlintScopes] is not empty.
  ///
  /// Used by brick to do conditional build.
  HookConfigsGetter<bool> get hasGitlintScopes {
    final key = "has-${BrickVars.gitlintScopes.key}";

    return (key: key, value: gitlintScopes.value.isNotEmpty);
  }

  HookConfigsGetter<String> get gitlintRefPrefix {
    final key = BrickVars.gitlintRefPrefix.key;
    final raw = _vars[key] as String;
    String value = raw;

    if (raw != "#") {
      if (!raw.endsWith("-")) value = "$raw-";
    }

    return (key: key, value: value);
  }

  /// Indicate that [gitlintRefPrefix] is not use default value.
  ///
  /// Used by brick to do conditional build.
  HookConfigsGetter<bool> get hasGitlintRefPrefix {
    final key = "has-${BrickVars.gitlintRefPrefix.key}";
    final refPrefix = gitlintRefPrefix.value;

    return (key: key, value: refPrefix != "#" || refPrefix.isEmpty);
  }

  HookConfigsGetter<String> get cdWorkflow {
    final key = "cd-workflow";
    final value = workflows.getCdWorkflow("/${projectName.value}/");

    return (key: key, value: value);
  }

  HookConfigsGetter<String> get ciPrWorkflow {
    final key = "ci-pr-workflow";
    final value = workflows.ciPrWorkflow;

    return (key: key, value: value);
  }

  HookConfigsGetter<String> get ciWorkflow {
    final key = "ci-workflow";
    final value = workflows.ciWorkflow;

    return (key: key, value: value);
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
