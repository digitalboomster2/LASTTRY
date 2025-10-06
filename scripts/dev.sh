#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 [web|ios]"
  exit 1
}

cd "$(dirname "$0")/.."

if [ $# -lt 1 ]; then usage; fi

target="$1"

if [ "$target" = "web" ]; then
  flutter run -d chrome
  exit $?
fi

if [ "$target" = "ios" ]; then
  # Best-effort prep for first builds
  flutter precache --ios || true
  open -a Simulator || true
  flutter run -d "iPhone 16 Plus"
  exit $?
fi

usage


