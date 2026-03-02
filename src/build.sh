#!/usr/bin/env bash
set -e

SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
IOS_VERSION=$(xcrun --sdk iphoneos --show-sdk-version)

#------------------------------------------------- 
# 1️⃣ Compile Swift sources
swiftc -target arm64-apple-ios16.0 -sdk "$SDKROOT" -O -parse-as-library -c AppDelegate.swift -o AppDelegate.o

#------------------------------------------------- 
# 2️⃣ Link into an iOS executable
clang -target arm64-apple-ios16.0 -isysroot "$SDKROOT" \
      AppDelegate.o -framework UIKit -framework AVFoundation \
      -framework UserNotifications -framework Foundation \
      -Wl,-rpath,@executable_path/Frameworks -o RayAssistant
#------------------------------------------------- 
# 3️⃣ Build the .app bundle
mkdir -p Payload/RayAssistant.app
cp RayAssistant Payload/RayAssistant.app/
cp Info.plist Payload/RayAssistant.app/
#------------------------------------------------- 
# 4️⃣ Package as unsigned IPA
zip -r9 RayAssistant.ipa Payload
echo "✅ IPA created at $(pwd)/RayAssistant.ipa"
