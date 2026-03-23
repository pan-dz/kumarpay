#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 (--version <x.y.z> | --tag) --build <number> --env <sit|test|prod> [--name <base_name>] [--target-platform <platform>] [--split-per-abi] [--output <apk_path> | --output-dir <dir>]"
  echo "Example: $0 --version 1.2.3 --build 45 --env sit --output build/apk/app-release.apk"
  echo "Example: $0 --name KumarPay-2601301640 --version 1.0.3 --build 45 --env sit --output-dir build/apk"
  echo "Example: $0 --name KumarPay-2601301640 --tag --build 45 --env prod --output-dir build/apk"
  echo "Example: $0 --name KumarPay-2601301640 --version 1.0.3 --build 45 --env prod --target-platform android-arm,android-arm64 --output-dir build/apk"
}

APP_NAME=""
BUILD_NAME=""
BUILD_NUMBER=""
APP_ENV=""
OUTPUT_APK=""
OUTPUT_DIR=""
USE_TAG="false"
TARGET_PLATFORM=""
SPLIT_PER_ABI="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      BUILD_NAME="$2"
      shift 2
      ;;
    --tag)
      USE_TAG="true"
      shift 1
      ;;
    --name)
      APP_NAME="$2"
      shift 2
      ;;
    --build)
      BUILD_NUMBER="$2"
      shift 2
      ;;
    --env)
      APP_ENV="$2"
      shift 2
      ;;
    --output)
      OUTPUT_APK="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --target-platform)
      TARGET_PLATFORM="$2"
      shift 2
      ;;
    --split-per-abi)
      SPLIT_PER_ABI="true"
      shift 1
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

if [[ "$USE_TAG" == "true" && -n "$BUILD_NAME" ]]; then
  echo "Please use only one of --version or --tag"
  usage
  exit 1
fi

if [[ -z "$BUILD_NUMBER" || -z "$APP_ENV" ]]; then
  usage
  exit 1
fi

if [[ "$USE_TAG" == "true" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "git is required for --tag but was not found"
    exit 1
  fi
  if ! BUILD_NAME=$(git describe --tags --abbrev=0 2>/dev/null); then
    echo "Failed to read git tag. Please create a tag or use --version"
    exit 1
  fi
fi

if [[ -z "$BUILD_NAME" ]]; then
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

ICON_CONFIG=""
if [[ "$APP_ENV" == "sit" ]]; then
  ICON_CONFIG="flutter_launcher_icons_dev.yaml"
elif [[ "$APP_ENV" == "prod" ]]; then
  ICON_CONFIG="flutter_launcher_icons_prod.yaml"
fi

if [[ -n "$ICON_CONFIG" ]]; then
  dart run flutter_launcher_icons -f "$ICON_CONFIG"
fi

SPLIT_DEBUG_INFO_DIR="build/symbols/${APP_ENV}"

TARGET_PLATFORM_ARGS=()
if [[ -n "$TARGET_PLATFORM" ]]; then
  TARGET_PLATFORM_ARGS=(--target-platform "$TARGET_PLATFORM")
else
  TARGET_PLATFORM_ARGS=(--target-platform "android-arm,android-arm64")
fi

SPLIT_PER_ABI_ARGS=()
if [[ "$SPLIT_PER_ABI" == "true" ]]; then
  SPLIT_PER_ABI_ARGS=(--split-per-abi)
fi

flutter build apk --release \
  --build-name "$BUILD_NAME" \
  --build-number "$BUILD_NUMBER" \
  --flavor "$APP_ENV" \
  --dart-define=APP_ENV="$APP_ENV" \
  --tree-shake-icons \
  --obfuscate \
  --split-debug-info="$SPLIT_DEBUG_INFO_DIR" \
  ${TARGET_PLATFORM_ARGS[@]:-} \
  ${SPLIT_PER_ABI_ARGS[@]:-}

APK_PATH="build/app/outputs/flutter-apk/app-${APP_ENV}-release.apk"
if [[ -n "$OUTPUT_APK" && -n "$OUTPUT_DIR" ]]; then
  echo "Please use only one of --output or --output-dir"
  exit 1
fi

if [[ -n "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
  if [[ -n "$APP_NAME" ]]; then
    OUTPUT_APK="$OUTPUT_DIR/${APP_NAME}.apk"
  else
    OUTPUT_APK="$OUTPUT_DIR/app-${APP_ENV}-release.apk"
  fi
fi

if [[ -n "$OUTPUT_APK" ]]; then
  mkdir -p "$(dirname "$OUTPUT_APK")"
  cp "$APK_PATH" "$OUTPUT_APK"
  echo "Generated: $OUTPUT_APK"
else
  echo "Generated: $APK_PATH"
fi
