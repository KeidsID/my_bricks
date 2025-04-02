# fl_app_plus

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

[dart-badge]:
  https://img.shields.io/badge/SDK-^3.7.2-red?style=flat&logo=dart&logoColor=2cb8f7&labelColor=333333&color=01579b
[fl-badge]:
  https://img.shields.io/badge/SDK-^3.29.2-red?style=flat&logo=flutter&logoColor=2cb8f7&labelColor=333333&color=01579b

![Dart version][dart-badge] ![Flutter][fl-badge]

Simple brick to create flutter app with my favorite stacks.

> You may need to update your flutter sdk version to v3.29.2 and above before
> you can use this brick-generated project.

## Features

[freezed]: https://pub.dev/packages/freezed
[injectable]: https://pub.dev/packages/injectable
[go_router]: https://pub.dev/packages/go_router
[riverpod]: https://riverpod.dev

- Pre-installed favorite dependencies:

  - [freezed]
  - [injectable]
  - [go_router] (Typed Route)
  - [riverpod]

- Can modify package import alias.

  ```dart
  // Instead this default package import
  import "package:my_flutter_app/main.dart";

  // You can do this
  import "package:mfa/main.dart";
  ```

  > Please note that this will change `pubspec.yaml` project name.

- Can set the display name of the app.

[release-please-action]: https://github.com/googleapis/release-please-action

- CI/CD that automates versioning and web deploy to github pages with the help
  of [release-please-action].

## Getting Started

Add `fl_app_plus` brick to your mason dependencies.

```yml
bricks:
  fl_app_plus:
    git:
      url: https://github.com/KeidsID/my_bricks.git
      path: bricks/fl_app_plus
```

And that's it. Now you can create your flutter app.

```sh
# get bricks
mason get

# generate new app
mason make fl_app_plus
```
