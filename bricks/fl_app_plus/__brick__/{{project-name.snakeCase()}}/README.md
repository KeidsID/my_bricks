# {{project-name.snakeCase()}}

[dart-badge]:
  https://img.shields.io/badge/SDK-^3.7.0-red?style=flat&logo=dart&logoColor=2cb8f7&labelColor=333333&color=01579b
[fl-badge]:
  https://img.shields.io/badge/SDK-^3.29.0-red?style=flat&logo=flutter&logoColor=2cb8f7&labelColor=333333&color=01579b

![Dart v3.7.0][dart-badge] ![Flutter v3.29.0][fl-badge]

{{desc}}

## Requirements

[fl-archive]: https://docs.flutter.dev/release/archive
[fvm]: https://fvm.app/documentation

- Install [Flutter SDK][fl-archive] with the same version as defined on
  [`pubspec.yaml`](pubspec.yaml) or [`.fvmrc`](.fvmrc) file.

  You may use [fvm] (Flutter Version Manager) for easy installation.

  ```sh
  fvm use
  ```

## Dependencies

Main packages that are used as foundation for this project.

[build_runner]: https://pub.dev/packages/build_runner
[injectable]: https://pub.dev/packages/injectable
[freezed]: https://pub.dev/packages/freezed
[go_router]: https://pub.dev/packages/go_router
[riverpod]: https://riverpod.dev

- [freezed] -- Data model with less boilerplate syntax.
- [injectable] -- Dependency injection framework.
- [go_router] -- Web friendly routing.
- [riverpod] -- State management.

Most of them need to generate its utilities with [build_runner].

## Setup

1. Install dependencies.

   ```sh
   flutter pub get
   ```

2. Intialize git hooks to validate commit messages.

   ```sh
   dart run husky install
   ```

3. Build project environment.

   ```sh
   dart run build_runner build -d # generate code utils
   ```

4. Now you're good to go!

   ```sh
   # Check connected devices
   flutter devices

   # Check available emulators
   flutter emulators

   # Run app
   flutter run -d <device-id>
   ```

## Git Conventions

[conventional-commits]: https://www.conventionalcommits.org

We use [conventional-commits] to handle Git commit messages, and Github PR
titles.

### Issue Title

```txt
<type>(<scopes(optional)>): <content>
```

Examples:

- `feat: add foo service`
- `bug: unresponsive bar page`

### Commit Message / PR Title

```txt
<type>(<scopes(optional)>): <content> {{gitlint-ref-prefix}}<issue-number>
```

Examples:

- `feat: add foo abstraction {{gitlint-ref-prefix}}89`
- `fix: fix invalid behavior of bar method {{gitlint-ref-prefix}}82`

### Branch Name

```txt
<type>-<content>-{{gitlint-ref-prefix}}<issue-number>
```

Examples:

- `chore-update-docs-{{gitlint-ref-prefix}}26`
- `fix-unresponsive-foo-page-{{gitlint-ref-prefix}}75`
