#!/bin/bash

# Exit on error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
XAMARIN_DIR="$PROJECT_ROOT/lib/xamarin"
IOS_DIR="$PROJECT_ROOT/ios"
ANDROID_DIR="$PROJECT_ROOT/android"

# Check if Xamarin libraries exist, if not create mock DLLs
if [ ! -d "$XAMARIN_DIR" ] || [ ! -f "$XAMARIN_DIR/ios/Msg.dll" ] || [ ! -f "$XAMARIN_DIR/android/Msg.dll" ]; then
  echo "Warning: Xamarin libraries not found. Creating mock DLLs for development."
  "$SCRIPT_DIR/create-mock-dlls.sh"
fi

echo "Integrating Xamarin NXP plugin with React Native..."

# iOS Integration
echo "Integrating with iOS..."
mkdir -p "$IOS_DIR/Frameworks"
cp -R "$XAMARIN_DIR/ios/"*.dll "$IOS_DIR/Frameworks/"

# Update the podspec to include the Xamarin libraries
cat > "$PROJECT_ROOT/NxpBridge.podspec" << EOL
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "NxpBridge"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => "https://github.com/sunyych/react-native-nxp-bridge.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"
  s.resource_bundles = {
    'NxpBridge' => ['ios/Frameworks/*.dll']
  }

  s.dependency "React-Core"
end
EOL

# Android Integration
echo "Integrating with Android..."
mkdir -p "$ANDROID_DIR/libs"
cp -R "$XAMARIN_DIR/android/"*.dll "$ANDROID_DIR/libs/"

# Update the build.gradle to include the Xamarin libraries
cat > "$ANDROID_DIR/build.gradle" << EOL
buildscript {
  repositories {
    google()
    mavenCentral()
  }

  dependencies {
    classpath "com.android.tools.build:gradle:7.2.1"
  }
}

def isNewArchitectureEnabled() {
  return rootProject.hasProperty("newArchEnabled") && rootProject.getProperty("newArchEnabled") == "true"
}

apply plugin: "com.android.library"

if (isNewArchitectureEnabled()) {
  apply plugin: "com.facebook.react"
}

android {
  compileSdkVersion 33
  namespace "com.nxpbridge"

  defaultConfig {
    minSdkVersion 21
    targetSdkVersion 33
  }

  sourceSets {
    main {
      java.srcDirs = ['src/main/java']
      jniLibs.srcDirs = ['libs']
    }
  }
}

repositories {
  mavenCentral()
  google()
}

dependencies {
  implementation "com.facebook.react:react-native:+"
  implementation fileTree(dir: "libs", include: ["*.dll"])
}
EOL

# Also ensure the example project has the libs directory
if [ -d "$PROJECT_ROOT/example/android/app" ]; then
  echo "Setting up example project Android libs directory..."
  mkdir -p "$PROJECT_ROOT/example/android/app/libs"
  cp -R "$XAMARIN_DIR/android/"*.dll "$PROJECT_ROOT/example/android/app/libs/"
fi

echo "Xamarin NXP plugin integrated successfully with React Native!"
