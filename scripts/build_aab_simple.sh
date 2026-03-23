#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 (--version <x.y.z> | --tag) --build <number> --env <sit|test|prod> [--name <base_name>] [--output <aab_path> | --output-dir <dir>]"
  echo "Example: $0 --name KumarPay-Test-2601311000 --version 1.0.5 --build 45 --env sit --output-dir build/aab"
  echo "Example: $0 --name KumarPay-2602011330 --tag --build 45 --env prod --output-dir build/aab"
}

APP_NAME=""
BUILD_NAME=""
BUILD_NUMBER=""
APP_ENV=""
OUTPUT_AAB=""
OUTPUT_DIR=""
USE_TAG="false"

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
      OUTPUT_AAB="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
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
  flutter pub run flutter_launcher_icons -f "$ICON_CONFIG"
fi

SPLIT_DEBUG_INFO_DIR="build/symbols/${APP_ENV}"

flutter build appbundle --release \
  --build-name "$BUILD_NAME" \
  --build-number "$BUILD_NUMBER" \
  --flavor "$APP_ENV" \
  --dart-define=APP_ENV="$APP_ENV" \
  --tree-shake-icons \
  --obfuscate \
  --split-debug-info="$SPLIT_DEBUG_INFO_DIR"

AAB_PATH="build/app/outputs/bundle/${APP_ENV}Release/app-${APP_ENV}-release.aab"
if [[ -n "$OUTPUT_AAB" && -n "$OUTPUT_DIR" ]]; then
  echo "Please use only one of --output or --output-dir"
  exit 1
fi

if [[ -n "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
  if [[ -n "$APP_NAME" ]]; then
    OUTPUT_AAB="$OUTPUT_DIR/${APP_NAME}.aab"
  else
    OUTPUT_AAB="$OUTPUT_DIR/app-${APP_ENV}-release.aab"
  fi
fi

if [[ -n "$OUTPUT_AAB" ]]; then
  mkdir -p "$(dirname "$OUTPUT_AAB")"
  cp "$AAB_PATH" "$OUTPUT_AAB"
  echo "Generated: $OUTPUT_AAB"
else
  echo "Generated: $AAB_PATH"
fi
