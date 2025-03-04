#!/bin/bash

# Exit on error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
OUTPUT_DIR="$PROJECT_ROOT/lib/xamarin"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/ios"
mkdir -p "$OUTPUT_DIR/android"

echo "Creating mock Xamarin DLLs for development..."

# Function to create a mock DLL
create_mock_dll() {
    local target_dir="$1"
    local dll_name="$2"

    echo "Creating mock $dll_name in $target_dir"
    echo "This is a mock DLL for development purposes only. Replace with actual Xamarin libraries in production." > "$target_dir/$dll_name"
}

# Create mock DLLs for iOS
create_mock_dll "$OUTPUT_DIR/ios" "Msg.dll"
create_mock_dll "$OUTPUT_DIR/ios" "Plugin.Ndef.dll"
create_mock_dll "$OUTPUT_DIR/ios" "Helpers.dll"

# Create mock DLLs for Android
create_mock_dll "$OUTPUT_DIR/android" "Msg.dll"
create_mock_dll "$OUTPUT_DIR/android" "Plugin.Ndef.dll"
create_mock_dll "$OUTPUT_DIR/android" "Helpers.dll"

echo "Mock Xamarin DLLs created successfully!"
echo "Output directory: $OUTPUT_DIR"

# Create directories for iOS frameworks
mkdir -p "$PROJECT_ROOT/ios/Frameworks"
echo "This is a placeholder for Xamarin iOS frameworks" > "$PROJECT_ROOT/ios/Frameworks/README.txt"

# Create directories for Android libraries
mkdir -p "$PROJECT_ROOT/android/libs"
echo "This is a placeholder for Xamarin Android libraries" > "$PROJECT_ROOT/android/libs/README.txt"

echo "Framework directories created successfully!"
