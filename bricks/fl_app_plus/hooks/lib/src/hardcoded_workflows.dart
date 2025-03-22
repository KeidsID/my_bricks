/// Since mason brick had conflicts with workflow bracket syntax,
/// the workflows will be hardcoded here.
/// 
/// https://github.com/felangel/mason/issues/503
library;

String getCdWorkflow(String webBaseHref) {
  return """
name: 🚀 Continuous Delivery

on:
  push:
    branches: [main]

concurrency:
  group: \${{ github.ref_name }}
  cancel-in-progress: false

jobs:
  release:
    name: 🚀 Release
    runs-on: ubuntu-latest

    permissions:
      contents: write
      pull-requests: write

    steps:
      - name: 📚 Code Checkout
        uses: actions/checkout@v4

      - name: 🚀 Release
        id: rp
        uses: googleapis/release-please-action@v4
        with:
          manifest-file: release.manifest.json
          config-file: release.config.json

    outputs:
      release_created: \${{ steps.rp.outputs.release_created }}
      created_tag: \${{ steps.rp.outputs.tag_name }}

  deps:
    name: 📦 Setup Dependencies For Deployment
    needs: release
    if: \${{ needs.release.outputs.release_created }}
    runs-on: macos-latest

    steps:
      - name: 📚 Code Checkout
        uses: actions/checkout@v4

      - name: 🐦 Setup Flutter SDK
        id: fl-setup
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: 3.29.x
          cache: true
          cache-key: |
            fl-:channel:-v:version:-:os:-:arch:-cd-\${{ hashFiles('./pubspec.lock') }}
          pub-cache-key: |
            fl-pub-:channel:-v:version:-:os:-:arch:-cd-\${{ hashFiles('./pubspec.lock') }}

      - name: 📦 Get dependencies
        run: flutter pub get

    outputs:
      release-tag: \${{ needs.release.outputs.created_tag }}
      fl-channel: \${{ steps.fl-setup.outputs.CHANNEL }}
      fl-version: \${{ steps.fl-setup.outputs.VERSION }}
      fl-cache-key: \${{ steps.fl-setup.outputs.CACHE-KEY }}
      fl-pub-cache-key: \${{ steps.fl-setup.outputs.PUB-CACHE-KEY }}

  web-github-pages:
    name: 🚀 Web Deploy on Github Pages
    needs: deps
    runs-on: macos-latest

    permissions:
      contents: write

    steps:
      - name: 📚 Code Checkout
        uses: actions/checkout@v4

      - name: 📦 Restore Dependencies
        uses: subosito/flutter-action@v2
        with:
          channel: \${{ needs.deps.outputs.fl-channel }}
          flutter-version: \${{ needs.deps.outputs.fl-version }}
          cache: true
          cache-key: \${{ needs.deps.outputs.fl-cache-key }}
          pub-cache-key: \${{ needs.deps.outputs.fl-pub-cache-key }}

      - name: 🏗️ Build code utils
        run: dart run build_runner build -d

      - name: 🏗️ Generate build number
        id: build-number
        uses: onyxmueller/build-tag-number@v1
        with:
          token: \${{ secrets.GITHUB_TOKEN }}
          prefix: "web--github-pages--"

      - name: 🏗️ Build web release
        env:
          BASE_HREF: "$webBaseHref"
          BUILD_NUMBER: \${{ steps.build-number.outputs.build_number }}
        run: |
          flutter build web --release --base-href \${{ env.BASE_HREF }} --build-number \${{ env.BUILD_NUMBER }}

      - name: 🚀 Deploy to Github Pages
        uses: peaceiris/actions-gh-pages@v3
        env:
          RELEASE_TAG: \${{ needs.deps.outputs.release-tag }}
          BUILD_NUMBER: \${{ steps.build-number.outputs.build_number }}
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
          publish_branch: web-release
          commit_message:
            "\${{ env.RELEASE_TAG }}+\${{ env.BUILD_NUMBER }} web release"

""";
}

String get ciPrWorkflow {
  return r"""
name: 🔍 Pull Request Continuous Integration

on:
  pull_request:
    types:
      - assigned
      - unassigned
      - opened
      - edited
      - synchronize
      - reopened
      - labeled
      - unlabeled
      - ready_for_review

concurrency:
  group: ci-pr-${{ github.ref }}
  cancel-in-progress: true

jobs:
  dependencies:
    name: 📦 Setup Dependencies
    runs-on: ubuntu-latest

    steps:
      - name: 📚 Code Checkout
        uses: actions/checkout@v4

      - name: 🐦 Setup Flutter SDK
        id: fl-setup
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: 3.29.x
          cache: true
          cache-key: |
            fl-:channel:-v:version:-:os:-:arch:-ci-pr-${{ hashFiles('./pubspec.lock') }}
          pub-cache-key: |
            fl-pub-:channel:-v:version:-:os:-:arch:-ci-pr-${{ hashFiles('./pubspec.lock') }}

      - name: 📦 Get dependencies
        run: flutter pub get

    outputs:
      fl-channel: ${{ steps.fl-setup.outputs.CHANNEL }}
      fl-version: ${{ steps.fl-setup.outputs.VERSION }}
      fl-cache-key: ${{ steps.fl-setup.outputs.CACHE-KEY }}
      fl-pub-cache-key: ${{ steps.fl-setup.outputs.PUB-CACHE-KEY }}

  ci-pr:
    name: 🔍 PR Linting
    needs: dependencies
    runs-on: ubuntu-latest

    permissions:
      contents: read
      pull-requests: write

    steps:
      - name: 📚 Code Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: 📦 Restore Dependencies
        uses: subosito/flutter-action@v2
        with:
          channel: ${{ needs.dependencies.outputs.fl-channel }}
          flutter-version: ${{ needs.dependencies.outputs.fl-version }}
          cache: true
          cache-key: ${{ needs.dependencies.outputs.fl-cache-key }}
          pub-cache-key: ${{ needs.dependencies.outputs.fl-pub-cache-key }}

      - name: 🏗️ Build code utils
        run: dart run build_runner build -d

      - name: ⚙️ Setup NodeJS
        uses: actions/setup-node@v3
        with:
          node-version: latest

      - name: 📦 Install DangerJs and DangerDart
        run: |
          npm install -g danger
          dart pub global activate danger_dart

      - name: 🔍 Lint Commits
        env:
          GH_PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}
          GH_PR_COMMITS: ${{ github.event.pull_request.commits }}
        run: |
          VERBOSE=true dart run commitlint_cli --from=${{ env.GH_PR_HEAD_SHA }}~${{ env.GH_PR_COMMITS }} --to=${{ env.GH_PR_HEAD_SHA }}

      - name: 🔍 Lint Pull Request
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          danger_dart ci --failOnErrors

""";
}

String get ciWorkflow {
  return r"""
name: 🔍 Continuous Integration

on:
  push:
    branches: [main]
    paths:
      - "{lib,test}/**"
      - "pubspec.*"
  pull_request:
    branches: [main]
    paths:
      - "{lib,test}/**"
      - "pubspec.*"

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  dependencies:
    name: 📦 Setup Dependencies
    runs-on: ubuntu-latest

    steps:
      - name: 📚 Code Checkout
        uses: actions/checkout@v4

      - name: 🐦 Setup Flutter SDK
        id: fl-setup
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: 3.29.x
          cache: true
          cache-key: |
            fl-:channel:-v:version:-:os:-:arch:-ci-${{ hashFiles('./pubspec.lock') }}
          pub-cache-key: |
            fl-pub-:channel:-v:version:-:os:-:arch:-ci-${{ hashFiles('./pubspec.lock') }}

      - name: 📦 Get dependencies
        run: flutter pub get

    outputs:
      fl-channel: ${{ steps.fl-setup.outputs.CHANNEL }}
      fl-version: ${{ steps.fl-setup.outputs.VERSION }}
      fl-cache-key: ${{ steps.fl-setup.outputs.CACHE-KEY }}
      fl-pub-cache-key: ${{ steps.fl-setup.outputs.PUB-CACHE-KEY }}

  lint:
    name: 🔍 Code Linting
    needs: dependencies
    runs-on: ubuntu-latest

    steps:
      - name: 📚 Code Checkout
        uses: actions/checkout@v4

      - name: 📦 Restore Dependencies
        uses: subosito/flutter-action@v2
        with:
          channel: ${{ needs.dependencies.outputs.fl-channel }}
          flutter-version: ${{ needs.dependencies.outputs.fl-version }}
          cache: true
          cache-key: ${{ needs.dependencies.outputs.fl-cache-key }}
          pub-cache-key: ${{ needs.dependencies.outputs.fl-pub-cache-key }}

      - name: 🏗️ Build code utils
        run: dart run build_runner build -d

      - name: 🔍 Code Linting
        run: |
          flutter analyze || dart analyze
          dart run custom_lint

""";
}
