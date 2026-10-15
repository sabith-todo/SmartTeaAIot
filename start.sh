#!/usr/bin/env bash
# SmartTea AIoT - Run script for Milestone 1 Flutter App
set -e

# Default to Linux desktop, or accept target device as first argument (e.g. ./start.sh chrome)
TARGET_DEVICE="${1:-linux}"

echo "Launching SmartTea AIoT on: $TARGET_DEVICE..."
flutter run -d "$TARGET_DEVICE"
