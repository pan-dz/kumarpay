#!/usr/bin/env bash
set -euo pipefail

setup_proxy_from_scutil() {
  if [[ -n "${HTTP_PROXY:-}" || -n "${HTTPS_PROXY:-}" || -n "${ALL_PROXY:-}" || -n "${http_proxy:-}" || -n "${https_proxy:-}" || -n "${all_proxy:-}" ]]; then
    return
  fi

  if ! command -v scutil >/dev/null 2>&1; then
    return
  fi

  local proxy_dump
  proxy_dump="$(scutil --proxy 2>/dev/null || true)"
  if [[ -z "$proxy_dump" ]]; then
    return
  fi

  local https_enable https_host https_port socks_enable socks_host socks_port
  https_enable="$(printf '%s\n' "$proxy_dump" | awk '/HTTPSEnable/ {print $3; exit}')"
  https_host="$(printf '%s\n' "$proxy_dump" | awk '/HTTPSProxy/ {print $3; exit}')"
  https_port="$(printf '%s\n' "$proxy_dump" | awk '/HTTPSPort/ {print $3; exit}')"
  socks_enable="$(printf '%s\n' "$proxy_dump" | awk '/SOCKSEnable/ {print $3; exit}')"
  socks_host="$(printf '%s\n' "$proxy_dump" | awk '/SOCKSProxy/ {print $3; exit}')"
  socks_port="$(printf '%s\n' "$proxy_dump" | awk '/SOCKSPort/ {print $3; exit}')"

  if [[ "$https_enable" == "1" && -n "$https_host" && -n "$https_port" ]]; then
    export HTTP_PROXY="http://$https_host:$https_port"
    export HTTPS_PROXY="http://$https_host:$https_port"
    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTPS_PROXY"
    echo "Using macOS HTTPS proxy: $https_host:$https_port"
  fi

  if [[ "$socks_enable" == "1" && -n "$socks_host" && -n "$socks_port" ]]; then
    export ALL_PROXY="socks5://$socks_host:$socks_port"
    export all_proxy="$ALL_PROXY"
    echo "Using macOS SOCKS proxy: $socks_host:$socks_port"
  fi
}

usage() {
  echo "Usage: $0 (--version <x.y.z> | --tag) --build <number> --env <sit|test|prod> [--artifact <apk|aab>] [--name <base_name>] [--output <path> | --output-dir <dir>] [--target-platform <platforms>] [--fast-arm64] [--skip-icons] [--dry-run]"
  echo "Example: $0 --version 1.0.38 --build 73 --env sit --artifact apk --output-dir build/apk"
  echo "Example (fast): $0 --version 1.0.38 --build 73 --env prod --artifact apk --fast-arm64 --skip-icons --output-dir build/apk"
  echo "Example: $0 --tag --build 73 --env sit --artifact aab --output-dir build/aab"
}

APP_NAME=""
BUILD_NAME=""
BUILD_NUMBER=""
APP_ENV=""
ARTIFACT="apk"
OUTPUT_PATH=""
OUTPUT_DIR=""
TARGET_PLATFORM=""
USE_TAG="false"
DRY_RUN="false"
SKIP_ICONS="false"
FAST_ARM64="false"

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
    --build)
      BUILD_NUMBER="$2"
      shift 2
      ;;
    --env)
      APP_ENV="$2"
      shift 2
      ;;
    --artifact)
      ARTIFACT="$2"
      shift 2
      ;;
    --name)
      APP_NAME="$2"
      shift 2
      ;;
    --output)
      OUTPUT_PATH="$2"
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
    --dry-run)
      DRY_RUN="true"
      shift 1
      ;;
    --skip-icons)
      SKIP_ICONS="true"
      shift 1
      ;;
    --fast-arm64)
      FAST_ARM64="true"
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
  BUILD_NAME="${BUILD_NAME#v}"
fi

if [[ -z "$BUILD_NAME" ]]; then
  usage
  exit 1
fi

setup_proxy_from_scutil

if [[ "$APP_ENV" == "test" ]]; then
  APP_ENV="sit"
fi

if [[ "$APP_ENV" != "sit" && "$APP_ENV" != "prod" ]]; then
  echo "Invalid --env value: $APP_ENV (use sit|test|prod)"
  exit 1
fi

ENV_LABEL=""
if [[ "$APP_ENV" == "sit" ]]; then
  ENV_LABEL="Test"
else
  ENV_LABEL="Prod"
fi

if [[ -z "$APP_NAME" ]]; then
  BUILD_TS=$(date +"%y%m%d%H%M")
  APP_NAME="KumarPay-${ENV_LABEL}-${BUILD_TS}-${BUILD_NAME}-${BUILD_NUMBER}"
fi

if [[ "$ARTIFACT" != "apk" && "$ARTIFACT" != "aab" ]]; then
  echo "Invalid --artifact value: $ARTIFACT (use apk|aab)"
  exit 1
fi

if [[ -n "$OUTPUT_PATH" && -n "$OUTPUT_DIR" ]]; then
  echo "Please use only one of --output or --output-dir"
  exit 1
fi

ICON_CONFIG=""
if [[ "$APP_ENV" == "sit" ]]; then
  ICON_CONFIG="flutter_launcher_icons_dev.yaml"
elif [[ "$APP_ENV" == "prod" ]]; then
  ICON_CONFIG="flutter_launcher_icons_prod.yaml"
fi

if [[ "$SKIP_ICONS" != "true" && -n "$ICON_CONFIG" ]]; then
  flutter pub run flutter_launcher_icons -f "$ICON_CONFIG"
fi

SPLIT_DEBUG_INFO_DIR="build/symbols/${APP_ENV}"

SHOREBIRD_ARGS=(
  release
  android
  --artifact "$ARTIFACT"
  --flavor "$APP_ENV"
  --build-name "$BUILD_NAME"
  --build-number "$BUILD_NUMBER"
  --dart-define "APP_ENV=$APP_ENV"
  --split-debug-info "$SPLIT_DEBUG_INFO_DIR"
  --no-confirm
)

if [[ -n "$TARGET_PLATFORM" ]]; then
  SHOREBIRD_ARGS+=(--target-platform "$TARGET_PLATFORM")
elif [[ "$ARTIFACT" == "apk" ]]; then
  if [[ "$FAST_ARM64" == "true" ]]; then
    SHOREBIRD_ARGS+=(--target-platform "android-arm64")
  else
    SHOREBIRD_ARGS+=(--target-platform "android-arm,android-arm64")
  fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
  SHOREBIRD_ARGS+=(--dry-run)
fi

shorebird "${SHOREBIRD_ARGS[@]}"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry run completed."
  exit 0
fi

ARTIFACT_PATH=""
if [[ "$ARTIFACT" == "aab" ]]; then
  ARTIFACT_PATH="build/app/outputs/bundle/${APP_ENV}Release/app-${APP_ENV}-release.aab"
else
  CANDIDATE_APK="build/app/outputs/flutter-apk/app-${APP_ENV}-release.apk"
  if [[ -f "$CANDIDATE_APK" ]]; then
    ARTIFACT_PATH="$CANDIDATE_APK"
  else
    LATEST_APK=$(ls -t build/app/outputs/flutter-apk/*.apk 2>/dev/null | head -n 1 || true)
    if [[ -z "$LATEST_APK" ]]; then
      echo "Cannot find generated APK in build/app/outputs/flutter-apk"
      exit 1
    fi
    ARTIFACT_PATH="$LATEST_APK"
  fi
fi

if [[ -n "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
  EXT="${ARTIFACT_PATH##*.}"
  OUTPUT_PATH="$OUTPUT_DIR/${APP_NAME}.${EXT}"
fi

if [[ -z "$OUTPUT_PATH" ]]; then
  EXT="${ARTIFACT_PATH##*.}"
  OUTPUT_PATH="$(dirname "$ARTIFACT_PATH")/${APP_NAME}.${EXT}"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"
cp "$ARTIFACT_PATH" "$OUTPUT_PATH"
echo "Generated: $OUTPUT_PATH"
