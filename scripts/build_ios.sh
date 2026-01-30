#!/bin/bash
# Build script for iOS native libraries
# Builds Rust core as a universal xcframework for iOS

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Rust core for iOS...${NC}"

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUST_CORE_DIR="$PROJECT_ROOT/core/null-space-core"
FLUTTER_APP_DIR="$PROJECT_ROOT/ui/null_space_app"
OUTPUT_DIR="$FLUTTER_APP_DIR/ios"
FRAMEWORK_NAME="NullSpaceCore"

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: cargo is not installed. Please install Rust.${NC}"
    exit 1
fi

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}Warning: iOS builds should be performed on macOS.${NC}"
    echo -e "${YELLOW}Continuing anyway, but the build may fail...${NC}"
fi

# iOS targets to build for
IOS_TARGETS=(
    "aarch64-apple-ios"           # iOS devices (ARM64)
    "aarch64-apple-ios-sim"       # iOS Simulator on Apple Silicon
    "x86_64-apple-ios"            # iOS Simulator on Intel
)

# Add iOS targets if not already installed
echo -e "${GREEN}Adding iOS targets...${NC}"
for target in "${IOS_TARGETS[@]}"; do
    echo "Adding target: $target"
    rustup target add "$target" || true
done

# Build for each target
cd "$RUST_CORE_DIR"

echo -e "${GREEN}Building for iOS device (aarch64-apple-ios)...${NC}"
cargo build --target aarch64-apple-ios --release

echo -e "${GREEN}Building for iOS Simulator (aarch64-apple-ios-sim)...${NC}"
cargo build --target aarch64-apple-ios-sim --release

echo -e "${GREEN}Building for iOS Simulator (x86_64-apple-ios)...${NC}"
cargo build --target x86_64-apple-ios --release

# Create temporary directory for framework creation
TEMP_DIR=$(mktemp -d)
# Ensure cleanup on exit (success or failure)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo -e "${GREEN}Creating XCFramework...${NC}"

# Create device framework
DEVICE_FRAMEWORK="$TEMP_DIR/ios-arm64/$FRAMEWORK_NAME.framework"
mkdir -p "$DEVICE_FRAMEWORK/Headers"
mkdir -p "$DEVICE_FRAMEWORK/Modules"

cp "target/aarch64-apple-ios/release/libnull_space_core.a" "$DEVICE_FRAMEWORK/$FRAMEWORK_NAME"

# Create Info.plist for device framework
cat > "$DEVICE_FRAMEWORK/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.nullspace.core</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>12.0</string>
</dict>
</plist>
EOF

# Create simulator framework (universal for arm64 and x86_64)
SIMULATOR_FRAMEWORK="$TEMP_DIR/ios-arm64_x86_64-simulator/$FRAMEWORK_NAME.framework"
mkdir -p "$SIMULATOR_FRAMEWORK/Headers"
mkdir -p "$SIMULATOR_FRAMEWORK/Modules"

# Create universal binary for simulator (both architectures)
lipo -create \
    "target/aarch64-apple-ios-sim/release/libnull_space_core.a" \
    "target/x86_64-apple-ios/release/libnull_space_core.a" \
    -output "$SIMULATOR_FRAMEWORK/$FRAMEWORK_NAME"

# Create Info.plist for simulator framework
cat > "$SIMULATOR_FRAMEWORK/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.nullspace.core</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>12.0</string>
</dict>
</plist>
EOF

# Create XCFramework
XCFRAMEWORK_PATH="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
rm -rf "$XCFRAMEWORK_PATH"

xcodebuild -create-xcframework \
    -framework "$DEVICE_FRAMEWORK" \
    -framework "$SIMULATOR_FRAMEWORK" \
    -output "$XCFRAMEWORK_PATH"

echo -e "${GREEN}iOS XCFramework built successfully!${NC}"
echo -e "XCFramework is located at: $XCFRAMEWORK_PATH"
echo ""
echo "The XCFramework includes:"
echo "  - iOS devices (arm64)"
echo "  - iOS Simulator (arm64, x86_64)"
