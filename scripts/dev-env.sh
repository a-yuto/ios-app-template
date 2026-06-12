# xcode-select が CommandLineTools を指している環境では、
#   - swiftlint が SourceKit (sourcekitdInProc) のロードに失敗して Fatal error で落ちる
#   - xcrun simctl が "unable to find utility simctl" になる
#   - fastlane scan も同根で壊れる
# ため、/Applications から Xcode.app を自動検出して DEVELOPER_DIR を export する (niki-sandbox#101)。
#
# 使い方 (必ず source すること。直接実行しても親シェルに反映されない):
#   source scripts/dev-env.sh
#
# 恒久的に直す場合は:
#   sudo xcode-select -s /Applications/Xcode-XX.app/Contents/Developer
#
# 注意: source される前提のため、このファイルに set -e 等を入れないこと。

if [ -z "${DEVELOPER_DIR:-}" ]; then
  case "$(xcode-select -p 2>/dev/null)" in
    *CommandLineTools*)
      _xcode_app=$(ls -d /Applications/Xcode*.app 2>/dev/null | sort -V | tail -1)
      if [ -n "$_xcode_app" ]; then
        export DEVELOPER_DIR="$_xcode_app/Contents/Developer"
        echo "dev-env.sh: DEVELOPER_DIR=$DEVELOPER_DIR" >&2
      else
        echo "dev-env.sh: /Applications に Xcode.app が見つかりません。Xcode をインストールしてください" >&2
      fi
      unset _xcode_app
      ;;
  esac
fi
