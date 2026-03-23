#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --env <sit|test|prod> [--name <dir_name>] [--pwa-strategy <offline-first|none>] [--output-dir <dir>] [--no-compress] [--wasm]"
  echo "Example: $0 --env prod --name KumarPay-2602011330 --output-dir build/web"
  echo "Example: $0 --env sit --pwa-strategy offline-first --no-compress"
}

APP_ENV=""
OUTPUT_DIR=""
OUTPUT_NAME=""
PWA_STRATEGY="offline-first"
ENABLE_COMPRESS="true"
ENABLE_WASM="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      APP_ENV="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --name)
      OUTPUT_NAME="$2"
      shift 2
      ;;
    --pwa-strategy)
      PWA_STRATEGY="$2"
      shift 2
      ;;
    --no-compress)
      ENABLE_COMPRESS="false"
      shift 1
      ;;
    --wasm)
      ENABLE_WASM="true"
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

if [[ -z "$APP_ENV" ]]; then
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

if [[ "$PWA_STRATEGY" != "offline-first" && "$PWA_STRATEGY" != "none" ]]; then
  echo "Invalid --pwa-strategy value: $PWA_STRATEGY (use offline-first|none)"
  exit 1
fi

if [[ -n "$OUTPUT_NAME" && -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="build/web-dist"
fi

if [[ -n "$OUTPUT_NAME" && "$OUTPUT_DIR" == "build/web"* ]]; then
  echo "--output-dir is under build/web, redirect to build/web-dist"
  OUTPUT_DIR="build/web-dist"
fi

BUILD_ARGS=(
  build web
  --release
  --tree-shake-icons
  --no-source-maps
  --pwa-strategy="$PWA_STRATEGY"
  --dart-define=APP_ENV="$APP_ENV"
)

if [[ "$ENABLE_WASM" == "true" ]]; then
  BUILD_ARGS+=(--wasm)
fi

flutter "${BUILD_ARGS[@]}"

SRC_DIR="build/web"
if [[ ! -d "$SRC_DIR" ]]; then
  echo "Build output not found: $SRC_DIR"
  exit 1
fi

TARGET_DIR="$SRC_DIR"
if [[ -n "$OUTPUT_DIR" || -n "$OUTPUT_NAME" ]]; then
  if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$SRC_DIR"
  fi

  if [[ -n "$OUTPUT_NAME" ]]; then
    TARGET_DIR="$OUTPUT_DIR/$OUTPUT_NAME"
  else
    TARGET_DIR="$OUTPUT_DIR"
  fi

  if [[ "$TARGET_DIR" != "$SRC_DIR" ]]; then
    mkdir -p "$TARGET_DIR"
    rsync -a --delete "$SRC_DIR"/ "$TARGET_DIR"/
  fi
fi

compress_assets() {
  local dir="$1"
  local gzip_cmd=""
  local brotli_cmd=""

  if command -v gzip >/dev/null 2>&1; then
    gzip_cmd="gzip"
  fi

  if command -v brotli >/dev/null 2>&1; then
    brotli_cmd="brotli"
  fi

  if [[ -z "$gzip_cmd" && -z "$brotli_cmd" ]]; then
    echo "gzip/brotli not found, skip compression"
    return 0
  fi

  while IFS= read -r -d '' file; do
    if [[ -n "$gzip_cmd" ]]; then
      gzip -9 -k -f "$file"
    fi
    if [[ -n "$brotli_cmd" ]]; then
      brotli -q 11 -f "$file"
    fi
  done < <(find "$dir" -type f \( \
      -name "*.js" -o -name "*.css" -o -name "*.html" -o -name "*.json" \
      -o -name "*.wasm" -o -name "*.svg" -o -name "*.xml" -o -name "*.txt" \
    \) -print0)
}

if [[ "$ENABLE_COMPRESS" == "true" ]]; then
  compress_assets "$TARGET_DIR"
fi

if [[ -n "$OUTPUT_NAME" && -d "$SRC_DIR" && "$TARGET_DIR" != "$SRC_DIR" ]]; then
  rm -rf "$SRC_DIR"
fi

echo "Generated: $TARGET_DIR"
