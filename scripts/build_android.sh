#!/bin/bash
# Build script for Android native libraries
# Builds Rust core for multiple Android architectures

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Rust core for Android...${NC}"

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUST_CORE_DIR="$PROJECT_ROOT/core/null-space-core"
FLUTTER_APP_DIR="$PROJECT_ROOT/ui/null_space_app"
OUTPUT_DIR="$FLUTTER_APP_DIR/android/app/src/main/jniLibs"

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: cargo is not installed. Please install Rust.${NC}"
    exit 1
fi

# Check if Android NDK is installed
if [ -z "$ANDROID_NDK_HOME" ] && [ -z "$NDK_HOME" ]; then
    echo -e "${YELLOW}Warning: ANDROID_NDK_HOME or NDK_HOME environment variable is not set.${NC}"
    echo -e "${YELLOW}Attempting to use cargo-ndk instead...${NC}"
    
    # Check if cargo-ndk is installed
    if ! command -v cargo-ndk &> /dev/null; then
        echo -e "${YELLOW}Installing cargo-ndk...${NC}"
        cargo install cargo-ndk
    fi
    USE_CARGO_NDK=true
else
    USE_CARGO_NDK=false
fi

# Android targets to build for
TARGETS=(
    "aarch64-linux-android:arm64-v8a"
    "armv7-linux-androideabi:armeabi-v7a"
    "x86_64-linux-android:x86_64"
)

# Add Android targets if not already installed
echo -e "${GREEN}Adding Android targets...${NC}"
for target_pair in "${TARGETS[@]}"; do
    target="${target_pair%%:*}"
    echo "Adding target: $target"
    rustup target add "$target" || true
done

# Build for each target
cd "$RUST_CORE_DIR"

for target_pair in "${TARGETS[@]}"; do
    rust_target="${target_pair%%:*}"
    android_arch="${target_pair##*:}"
    
    echo -e "${GREEN}Building for $android_arch ($rust_target)...${NC}"
    
    if [ "$USE_CARGO_NDK" = true ]; then
        # Build using cargo-ndk (automatically handles NDK paths)
        # Note: cargo-ndk expects Android architecture names, not Rust target triples
        cargo ndk -t "$android_arch" --platform 21 build --release
    else
        # Build using cargo with explicit NDK paths
        cargo build --target "$rust_target" --release
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR/$android_arch"
    
    # Copy the library to the Flutter project
    # Note: cargo-ndk places output in standard target directory with Rust target name
    cp "target/$rust_target/release/libnull_space_core.so" "$OUTPUT_DIR/$android_arch/"
    
    echo -e "${GREEN}✓ Built for $android_arch${NC}"
done

echo -e "${GREEN}Android native libraries built successfully!${NC}"
echo -e "Libraries are located in: $OUTPUT_DIR"
echo ""
echo "Architecture mapping:"
echo "  - arm64-v8a: 64-bit ARM devices (most modern Android devices)"
echo "  - armeabi-v7a: 32-bit ARM devices (older Android devices)"
echo "  - x86_64: 64-bit x86 emulators and tablets"
