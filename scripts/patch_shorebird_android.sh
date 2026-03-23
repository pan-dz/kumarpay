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
  echo "Usage: $0 --env <sit|test|prod> --release-version <x.y.z+build> [--track <stable|beta>] [--skip-release-check] [--verbose] [--dry-run]"
  echo "Example: $0 --env prod --release-version 1.0.31+68"
  echo "Example: $0 --env prod --release-version 1.0.31+68 --skip-release-check"
  echo "Example: $0 --env sit --release-version 1.0.31+68 --verbose"
  echo "Example: $0 --env sit --release-version 1.0.31+68 --dry-run"
}

APP_ENV=""
RELEASE_VERSION=""
TRACK="stable"
DRY_RUN="false"
SKIP_RELEASE_CHECK="false"
VERBOSE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      APP_ENV="$2"
      shift 2
      ;;
    --release-version)
      RELEASE_VERSION="$2"
      shift 2
      ;;
    --track)
      TRACK="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift 1
      ;;
    --skip-release-check)
      SKIP_RELEASE_CHECK="true"
      shift 1
      ;;
    --verbose)
      VERBOSE="true"
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

if [[ -z "$APP_ENV" || -z "$RELEASE_VERSION" ]]; then
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

if [[ "$TRACK" != "stable" && "$TRACK" != "beta" ]]; then
  echo "Invalid --track value: $TRACK (use stable|beta)"
  exit 1
fi

if [[ "$SKIP_RELEASE_CHECK" != "true" ]]; then
  CHECK_TMP_DIR="$(mktemp -d -t shorebird-release-check-XXXXXX)"
  CHECK_OUT_DIR="$CHECK_TMP_DIR/apks"
  CHECK_LOG_FILE="$CHECK_TMP_DIR/check_get_apks.log"
  CHECK_DRY_RUN_LOG_FILE="$CHECK_TMP_DIR/check_patch_dry_run.log"
  trap 'rm -rf "$CHECK_TMP_DIR"' EXIT

  echo "Checking release exists: flavor=$APP_ENV, version=$RELEASE_VERSION"
  if ! shorebird releases get-apks \
    --release-version "$RELEASE_VERSION" \
    --flavor "$APP_ENV" \
    --out "$CHECK_OUT_DIR" \
    --no-universal >"$CHECK_LOG_FILE" 2>&1; then
    echo "Primary check failed (get-apks). Running fallback check (patch --dry-run)..."
    if ! shorebird patch android \
      --flavor "$APP_ENV" \
      --release-version "$RELEASE_VERSION" \
      --track "$TRACK" \
      --dart-define "APP_ENV=$APP_ENV" \
      --no-confirm \
      --dry-run >"$CHECK_DRY_RUN_LOG_FILE" 2>&1; then
      echo "Release not found or inaccessible: flavor=$APP_ENV, version=$RELEASE_VERSION"
      echo "Tip: run shorebird release first, then patch."
      if [[ "$VERBOSE" == "true" ]]; then
        echo "----- Shorebird 原始错误（get-apks）开始 -----"
        cat "$CHECK_LOG_FILE"
        echo "----- Shorebird 原始错误（get-apks）结束 -----"
        echo "----- Shorebird 原始错误（patch --dry-run）开始 -----"
        cat "$CHECK_DRY_RUN_LOG_FILE"
        echo "----- Shorebird 原始错误（patch --dry-run）结束 -----"
      fi
      exit 1
    else
      echo "Fallback check passed. Release exists, continue patch."
      if [[ "$VERBOSE" == "true" ]]; then
        echo "----- Shorebird 原始信息（get-apks 失败）开始 -----"
        cat "$CHECK_LOG_FILE"
        echo "----- Shorebird 原始信息（get-apks 失败）结束 -----"
      fi
    fi
  fi

  rm -rf "$CHECK_TMP_DIR"
  trap - EXIT
fi

SHOREBIRD_ARGS=(
  patch
  android
  --flavor "$APP_ENV"
  --release-version "$RELEASE_VERSION"
  --track "$TRACK"
  --dart-define "APP_ENV=$APP_ENV"
  --no-confirm
)

if [[ "$DRY_RUN" == "true" ]]; then
  SHOREBIRD_ARGS+=(--dry-run)
fi

shorebird "${SHOREBIRD_ARGS[@]}"
