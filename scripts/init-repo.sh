#!/bin/bash

# Script to initialize a new git repository with the proper structure

echo "Initializing new git repository for NXP Bridge..."

# Navigate to the project root
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# Remove existing git repository if it exists
if [ -d ".git" ]; then
  echo "Removing existing git repository..."
  rm -rf .git
fi

# Initialize a new git repository
echo "Creating new git repository..."
git init

# Add .gitignore file if it doesn't exist
if [ ! -f ".gitignore" ]; then
  echo "Creating .gitignore file..."
  cat > .gitignore << EOL
# OSX
.DS_Store

# Node
node_modules
npm-debug.log
yarn-error.log
package-lock.json

# Xcode
build/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata
*.xccheckout
*.moved-aside
DerivedData
*.hmap
*.ipa
*.xcuserstate
ios/.xcode.env.local
example/ios/Pods/
example/ios/Podfile.lock
example/ios/build/
example/ios/*.xcworkspace
example/ios/DerivedData/

# Android/IntelliJ
build/
.idea
.gradle
local.properties
*.iml
*.hprof
.cxx/
*.keystore
!debug.keystore
example/android/app/build/
example/android/.gradle/
example/android/build/
example/android/local.properties

# Xamarin
xamarin/
*.dll
!scripts/mock-dlls/*.dll

# React Native
.expo/
.bundle/
lib/

# BUCK
buck-out/
\.buckd/
*.keystore
!debug.keystore

# fastlane
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots
**/fastlane/test_output

# Bundle artifact
*.jsbundle

# CocoaPods
/ios/Pods/
/example/ios/Pods/

# Testing
/coverage

# Temporary files
tmp/
temp/

# Generated files
lib/
.bob/
EOL
fi

# Add all files to git
echo "Adding files to git..."
git add .

# Make initial commit
echo "Making initial commit..."
git commit -m "Initial commit"

echo "Git repository initialized successfully."
echo "You can now push this repository to GitHub or another remote repository."
