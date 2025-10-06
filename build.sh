#!/bin/bash

# Configure git to handle the ownership issue
git config --global --add safe.directory /tmp/flutter

# Add Flutter to PATH
export PATH="$PATH:/tmp/flutter/bin"

# Show initial directory
echo "Initial directory: $(pwd)"
echo "VERCEL_BUILD_DIR: $VERCEL_BUILD_DIR"

# Find the project directory with pubspec.yaml
PROJECT_DIR=""
if [ -f "pubspec.yaml" ]; then
    PROJECT_DIR="$(pwd)"
    echo "Found pubspec.yaml in current directory"
elif [ -f "$VERCEL_BUILD_DIR/pubspec.yaml" ]; then
    PROJECT_DIR="$VERCEL_BUILD_DIR"
    echo "Found pubspec.yaml in VERCEL_BUILD_DIR"
else
    # Search for pubspec.yaml in subdirectories
    echo "Searching for pubspec.yaml..."
    PROJECT_DIR=$(find . -name "pubspec.yaml" -type f | head -1 | xargs dirname)
    if [ -n "$PROJECT_DIR" ]; then
        echo "Found pubspec.yaml in: $PROJECT_DIR"
    else
        echo "Could not find pubspec.yaml anywhere!"
        echo "Current directory contents:"
        ls -la
        echo "Searching recursively:"
        find . -name "*.yaml" -type f
        exit 1
    fi
fi

# Navigate to project directory
echo "Navigating to project directory: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Show current directory and contents
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

# Verify Flutter is available
echo "Verifying Flutter installation..."
flutter --version

# Check if pubspec.yaml exists
echo "Checking for pubspec.yaml..."
if [ -f "pubspec.yaml" ]; then
    echo "pubspec.yaml found!"
else
    echo "pubspec.yaml not found in current directory"
    exit 1
fi

# Build Flutter web app with optimizations
echo "Building Flutter web app..."
flutter build web --release --base-href / --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful!"
else
    echo "Build failed!"
    exit 1
fi

# Verify build output
echo "Build output verification:"
if [ -d "build" ]; then
    echo "build/ directory exists"
    ls -la build/
    if [ -d "build/web" ]; then
        echo "build/web/ directory exists"
        ls -la build/web/
        if [ -f "build/web/index.html" ]; then
            echo "index.html exists"
            echo "First 10 lines of index.html:"
            head -10 build/web/index.html
        else
            echo "ERROR: index.html not found!"
            exit 1
        fi
    else
        echo "ERROR: build/web/ directory not found!"
        exit 1
    fi
else
    echo "ERROR: build/ directory not found!"
    exit 1
fi

echo "Build completed successfully!"
