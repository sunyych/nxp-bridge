#!/bin/bash

# Script to fix common build issues for both iOS and Android

echo "Fixing build issues for NXP Bridge..."

# Navigate to the project root
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# Fix iOS build issues
echo "Fixing iOS build issues..."

# Check if the example directory exists
if [ -d "$PROJECT_ROOT/example" ]; then
  cd "$PROJECT_ROOT/example/ios"

  # Clean Pods
  echo "Cleaning iOS Pods..."
  rm -rf Pods Podfile.lock

  # Install Pods
  echo "Installing iOS Pods..."
  pod install

  # Fix Xcode project settings
  echo "Updating Xcode project settings..."
  # This is a placeholder for any specific Xcode project fixes
  # You may need to use PlistBuddy or other tools to modify project settings

  echo "iOS fixes completed."
else
  echo "Example directory not found. Skipping iOS fixes."
fi

# Fix Android build issues
echo "Fixing Android build issues..."

if [ -d "$PROJECT_ROOT/example" ]; then
  cd "$PROJECT_ROOT/example/android"

  # Clean Gradle
  echo "Cleaning Android Gradle..."
  ./gradlew clean

  # Fix Android Manifest if needed
  echo "Checking Android Manifest..."
  # This is a placeholder for any specific Android Manifest fixes

  echo "Android fixes completed."
else
  echo "Example directory not found. Skipping Android fixes."
fi

# Return to the project root
cd "$PROJECT_ROOT"

# Create necessary directories if they don't exist
echo "Creating necessary directories..."

# Ensure iOS Frameworks directory exists
mkdir -p "$PROJECT_ROOT/ios/Frameworks"

# Ensure Android libs directory exists
mkdir -p "$PROJECT_ROOT/example/android/app/libs"

# Run the mock DLL creation script if it exists
if [ -f "$PROJECT_ROOT/scripts/create-mock-dlls.sh" ]; then
  echo "Creating mock DLLs..."
  "$PROJECT_ROOT/scripts/create-mock-dlls.sh"
fi

# Run the integration script if it exists
if [ -f "$PROJECT_ROOT/scripts/integrate-xamarin.sh" ]; then
  echo "Integrating Xamarin libraries..."
  "$PROJECT_ROOT/scripts/integrate-xamarin.sh"
fi

echo "Build fixes completed. You can now try building the project again."
