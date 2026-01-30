#!/bin/bash
# Build script for macOS native libraries
# Builds Rust core as a universal dylib for macOS

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Rust core for macOS...${NC}"

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUST_CORE_DIR="$PROJECT_ROOT/core/null-space-core"
FLUTTER_APP_DIR="$PROJECT_ROOT/ui/null_space_app"
OUTPUT_DIR="$FLUTTER_APP_DIR/macos"

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: cargo is not installed. Please install Rust.${NC}"
    exit 1
fi

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}Warning: macOS builds should be performed on macOS.${NC}"
    echo -e "${YELLOW}Continuing anyway, but the build may fail...${NC}"
fi

# macOS targets to build for
MACOS_TARGETS=(
    "aarch64-apple-darwin"   # Apple Silicon (M1/M2/M3)
    "x86_64-apple-darwin"    # Intel Macs
)

# Add macOS targets if not already installed
echo -e "${GREEN}Adding macOS targets...${NC}"
for target in "${MACOS_TARGETS[@]}"; do
    echo "Adding target: $target"
    rustup target add "$target" || true
done

# Build for each target
cd "$RUST_CORE_DIR"

echo -e "${GREEN}Building for Apple Silicon (aarch64-apple-darwin)...${NC}"
cargo build --target aarch64-apple-darwin --release

echo -e "${GREEN}Building for Intel (x86_64-apple-darwin)...${NC}"
cargo build --target x86_64-apple-darwin --release

# Create universal binary
echo -e "${GREEN}Creating universal binary...${NC}"
mkdir -p "$OUTPUT_DIR/Frameworks"

lipo -create \
    "target/aarch64-apple-darwin/release/libnull_space_core.dylib" \
    "target/x86_64-apple-darwin/release/libnull_space_core.dylib" \
    -output "$OUTPUT_DIR/Frameworks/libnull_space_core.dylib"

# Set proper install name for the dylib
install_name_tool -id "@rpath/libnull_space_core.dylib" "$OUTPUT_DIR/Frameworks/libnull_space_core.dylib"

echo -e "${GREEN}macOS universal library built successfully!${NC}"
echo -e "Library is located at: $OUTPUT_DIR/Frameworks/libnull_space_core.dylib"
echo ""
echo "The universal binary includes:"
echo "  - Apple Silicon (arm64)"
echo "  - Intel (x86_64)"
echo ""
echo "Minimum macOS version: 10.14 (Mojave)"
