#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --name <base_name> (--version <x.y.z> | --tag) --build <number> --env <sit|test|prod> [--output-dir <dir>]"
  echo "Example: $0 --name KumarPay-test-2601281640 --version 1.2.3 --build 45 --env sit --output-dir build/apk"
  echo "Example (from Git tag): $0 --name KumarPay-prod-2601291645 --tag --build 45 --env prod --output-dir build/apk"
}

APP_NAME=""
BUILD_NAME=""
BUILD_NUMBER=""
OUTPUT_DIR=""
APP_ENV=""
USE_GIT_TAG=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      APP_NAME="$2"
      shift 2
      ;;
    --version)
      BUILD_NAME="$2"
      shift 2
      ;;
    --build)
      BUILD_NUMBER="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --env)
      APP_ENV="$2"
      shift 2
      ;;
    --tag)
      USE_GIT_TAG=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1"
      usage
      exit 1
      ;;
  esac
 done

if [[ -z "$APP_NAME" || -z "$BUILD_NUMBER" || -z "$APP_ENV" ]]; then
  usage
  exit 1
fi

if [[ "$APP_ENV" == "test" ]]; then
  APP_ENV="sit"
fi

if [[ "$APP_ENV" != "sit" && "$APP_ENV" != "prod" ]]; then
  echo "Invalid --env value: $APP_ENV (use sit|test|prod)"
  exit 1
fi

if $USE_GIT_TAG; then
  TAG_NAME="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  if [[ -z "$TAG_NAME" ]]; then
    echo "No Git tag found. Please create a tag or use --version."
    exit 1
  fi
  BUILD_NAME="${TAG_NAME#v}"
fi

if [[ -z "$BUILD_NAME" ]]; then
  usage
  exit 1
fi

ICON_CONFIG=""
if [[ "$APP_ENV" == "sit" ]]; then
  ICON_CONFIG="flutter_launcher_icons_dev.yaml"
elif [[ "$APP_ENV" == "prod" ]]; then
  ICON_CONFIG="flutter_launcher_icons_prod.yaml"
fi

if [[ -n "$ICON_CONFIG" ]]; then
  flutter pub run flutter_launcher_icons -f "$ICON_CONFIG"
fi

SPLIT_DEBUG_INFO_DIR="build/symbols/${APP_ENV}"

flutter build apk --release --split-per-abi \
  --build-name "$BUILD_NAME" \
  --build-number "$BUILD_NUMBER" \
  --flavor "$APP_ENV" \
  --dart-define=APP_ENV="$APP_ENV" \
  --tree-shake-icons \
  --obfuscate \
  --split-debug-info="$SPLIT_DEBUG_INFO_DIR"

APK_DIR="build/app/outputs/flutter-apk"
OUTPUT_DIR="${OUTPUT_DIR:-${APK_DIR}/custom}"

mkdir -p "$OUTPUT_DIR"

shopt -s nullglob
  for apk in "$APK_DIR"/app-*-release.apk; do
    filename="$(basename "$apk")"
    abi="${filename#app-}"
    abi="${abi%-release.apk}"

    case "$abi" in
      arm64-v8a) abi_short="v8a" ;;
      armeabi-v7a) abi_short="v7a" ;;
      *) abi_short="$abi" ;;
    esac

    new_name="${APP_NAME}-${abi_short}.apk"
    cp "$apk" "$OUTPUT_DIR/$new_name"
    echo "Generated: $OUTPUT_DIR/$new_name"
  done
