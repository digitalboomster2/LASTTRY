#!/bin/bash

# Install Flutter
echo "Installing Flutter..."
cd /tmp
curl -L -o flutter_linux.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar xf flutter_linux.tar.xz

# Configure git to handle the ownership issue AFTER extraction
cd /tmp/flutter
git config --global --add safe.directory /tmp/flutter

# Fix ownership of Flutter directory
chown -R $(whoami):$(whoami) /tmp/flutter

# Add Flutter to PATH
export PATH="$PATH:/tmp/flutter/bin"

# Verify Flutter installation
flutter --version

# Navigate back to project directory
cd $VERCEL_BUILD_DIR

# Install Flutter dependencies
echo "Installing Flutter dependencies..."
flutter pub get

echo "Install completed!"
