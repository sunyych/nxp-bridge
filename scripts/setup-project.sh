#!/bin/bash

# Exit on error
set -e

# Check if the project path is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <path-to-react-native-project>"
  exit 1
fi

PROJECT_PATH="$1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BRIDGE_DIR="$SCRIPT_DIR/.."

# Check if the project exists
if [ ! -d "$PROJECT_PATH" ]; then
  echo "Error: Project directory does not exist: $PROJECT_PATH"
  exit 1
fi

# Check if it's a React Native project
if [ ! -f "$PROJECT_PATH/package.json" ]; then
  echo "Error: Not a valid React Native project. package.json not found."
  exit 1
fi

echo "Setting up NXP Bridge in your React Native project..."

# Install the NXP Bridge package
echo "Installing NXP Bridge package..."
cd "$PROJECT_PATH"
yarn add "$BRIDGE_DIR"

# iOS setup
if [ -d "$PROJECT_PATH/ios" ]; then
  echo "Setting up iOS..."

  # Check if Podfile exists
  if [ ! -f "$PROJECT_PATH/ios/Podfile" ]; then
    echo "Error: Podfile not found in iOS directory."
    exit 1
  fi

  # Add the NXP Bridge pod to the Podfile if it's not already there
  if ! grep -q "pod 'NxpBridge'" "$PROJECT_PATH/ios/Podfile"; then
    echo "Adding NxpBridge pod to Podfile..."
    sed -i '' '/use_react_native/a\
  pod "NxpBridge", :path => "../node_modules/react-native-nxp-bridge/NxpBridge.podspec"
' "$PROJECT_PATH/ios/Podfile"
  fi

  # Install pods
  echo "Installing pods..."
  cd "$PROJECT_PATH/ios"
  pod install
fi

# Android setup
if [ -d "$PROJECT_PATH/android" ]; then
  echo "Setting up Android..."

  # Create directory for Xamarin libraries
  mkdir -p "$PROJECT_PATH/android/app/src/main/assets/xamarin"

  # Copy Xamarin libraries
  echo "Copying Xamarin libraries..."
  cp -R "$BRIDGE_DIR/lib/xamarin/android/"*.dll "$PROJECT_PATH/android/app/src/main/assets/xamarin/"
fi

echo "NXP Bridge setup complete!"
echo "You can now import and use the NXP Bridge in your React Native project."
echo "See the documentation for usage examples: https://github.com/sunyych/react-native-nxp-bridge#usage"
