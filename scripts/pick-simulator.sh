#!/usr/bin/env bash
# 利用可能な iPhone Simulator から優先度順に1つ選び、UDID を標準出力に書き出す。
# CI とローカルで同じロジックを共有することで、Xcode のバージョン差や手元に入っている
# シミュレータの違いに左右されずにテストを流せるようにする。
#
# 使い方:
#   UDID=$(scripts/pick-simulator.sh)
#   xcodebuild -destination "id=$UDID" ...
#
# 明示的に使いたい simulator がある場合は環境変数で上書き:
#   SIMULATOR_NAME="iPhone 16 Pro" scripts/pick-simulator.sh

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "pick-simulator.sh: 'jq' が必要です (brew install jq)" >&2
  exit 1
fi

pick_udid_by_name() {
  local name="$1"
  xcrun simctl list devices available --json \
    | jq -r --arg name "$name" '
      [ .devices
        | to_entries[]
        | select(.key | test("com.apple.CoreSimulator.SimRuntime.iOS"))
        | .value[]
        | select(.isAvailable == true)
        | select(.name == $name)
      ] | first | (.udid // empty)'
}

if [[ -n "${SIMULATOR_NAME:-}" ]]; then
  UDID=$(pick_udid_by_name "$SIMULATOR_NAME")
  if [[ -z "$UDID" ]]; then
    echo "pick-simulator.sh: SIMULATOR_NAME='$SIMULATOR_NAME' に一致する simulator が見つかりません" >&2
    exit 1
  fi
  echo "$UDID"
  exit 0
fi

# 新しめのモデルを優先。A15 以前の SE 系は XCUITest が不安定なため後回し。
PREFERRED=(
  "iPhone 17 Pro Max" "iPhone 17 Pro" "iPhone 17" "iPhone 17e"
  "iPhone Air"
  "iPhone 16 Pro Max" "iPhone 16 Pro" "iPhone 16 Plus" "iPhone 16"
  "iPhone 15 Pro Max" "iPhone 15 Pro" "iPhone 15 Plus" "iPhone 15"
)

for name in "${PREFERRED[@]}"; do
  UDID=$(pick_udid_by_name "$name")
  if [[ -n "$UDID" ]]; then
    echo "$UDID"
    exit 0
  fi
done

# フォールバック: 任意の iPhone (SE 含む)
UDID=$(xcrun simctl list devices available --json \
  | jq -r '
    [ .devices
      | to_entries[]
      | select(.key | test("com.apple.CoreSimulator.SimRuntime.iOS"))
      | .value[]
      | select(.isAvailable == true)
      | select(.name | startswith("iPhone"))
    ] | first | (.udid // empty)')

if [[ -z "$UDID" ]]; then
  echo "pick-simulator.sh: iPhone simulator が見つかりませんでした" >&2
  exit 1
fi

echo "$UDID"
