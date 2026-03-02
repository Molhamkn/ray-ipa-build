#!/usr/bin/env bash
set -e

SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)

#------------------------------------------------- 
# 1️⃣ Compile Swift sources separately
swiftc -target arm64-apple-ios13.0 -sdk "$SDKROOT" -O -c AppDelegate.swift -o AppDelegate.o
swiftc -target arm64-apple-ios13.0 -sdk "$SDKROOT" -O -c main.swift -o main.o

#------------------------------------------------- 
# 2️⃣ Link into an iOS executable
clang -target arm64-apple-ios13.0 -isysroot "$SDKROOT" \
      AppDelegate.o main.o -framework UIKit -framework AVFoundation \
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
