#!/bin/sh
# Xcode Cloud post-clone hook
#
# このテンプレートの既定 CI は Xcode Cloud。Xcode Cloud は共有スキーム
# (ios-app-template.xcodeproj/xcshareddata/xcschemes/ios-app-template.xcscheme) の
# Test アクションで Build + Unit + UITest を実行する (UI テストは scheme 側で
# parallelizable = "NO": niki-sandbox#107)。
#
# このスクリプトは clone 直後・xcodebuild 開始前に1回だけ走る。ここで:
#   1. SwiftLint を入れる (Xcode Cloud には未インストール)
#   2. SwiftLint --strict をゲートとして実行する
# 非0で終了すると Xcode Cloud のビルドは失敗する (= lint ゲート、旧 GHA の
# lint ジョブ相当)。
#
# 実行時のカレントディレクトリは ci_scripts/。リポジトリルートは
# $CI_PRIMARY_REPOSITORY_PATH (.swiftlint.yml が置かれている場所)。
set -e

echo "--- Installing SwiftLint ---"
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_AUTO_UPDATE=1
brew install swiftlint

echo "--- SwiftLint (--strict) ---"
cd "$CI_PRIMARY_REPOSITORY_PATH"
swiftlint --strict --reporter emoji

echo "--- post_clone done ---"
