#!/bin/bash
# Master build script for all platforms
# Builds Rust core for Android, iOS, macOS, and/or Windows

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Display usage information
usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Build Rust native libraries for Flutter platforms."
    echo ""
    echo "Options:"
    echo "  -a, --android     Build for Android (arm64-v8a, armeabi-v7a, x86_64)"
    echo "  -i, --ios         Build for iOS (xcframework)"
    echo "  -m, --macos       Build for macOS (universal binary)"
    echo "  -w, --windows     Build for Windows (x64 DLL)"
    echo "  --all             Build for all platforms"
    echo "  -h, --help        Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --android           # Build for Android only"
    echo "  $0 --android --ios     # Build for Android and iOS"
    echo "  $0 --all               # Build for all platforms"
    echo ""
}

# Parse command line arguments
BUILD_ANDROID=false
BUILD_IOS=false
BUILD_MACOS=false
BUILD_WINDOWS=false

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No build targets specified.${NC}"
    echo ""
    usage
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--android)
            BUILD_ANDROID=true
            shift
            ;;
        -i|--ios)
            BUILD_IOS=true
            shift
            ;;
        -m|--macos)
            BUILD_MACOS=true
            shift
            ;;
        -w|--windows)
            BUILD_WINDOWS=true
            shift
            ;;
        --all)
            BUILD_ANDROID=true
            BUILD_IOS=true
            BUILD_MACOS=true
            BUILD_WINDOWS=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            echo ""
            usage
            exit 1
            ;;
    esac
done

# Build summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Null Space - Native Library Builder${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Build targets:"
[ "$BUILD_ANDROID" = true ] && echo -e "  ${GREEN}✓${NC} Android"
[ "$BUILD_IOS" = true ] && echo -e "  ${GREEN}✓${NC} iOS"
[ "$BUILD_MACOS" = true ] && echo -e "  ${GREEN}✓${NC} macOS"
[ "$BUILD_WINDOWS" = true ] && echo -e "  ${GREEN}✓${NC} Windows"
echo ""

# Track build results
BUILDS_SUCCESS=0
BUILDS_FAILED=0
BUILDS_SKIPPED=0
FAILED_PLATFORMS=()
SKIPPED_PLATFORMS=()

# Build for Android
if [ "$BUILD_ANDROID" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if bash "$SCRIPT_DIR/build_android.sh"; then
        ((BUILDS_SUCCESS++))
    else
        ((BUILDS_FAILED++))
        FAILED_PLATFORMS+=("Android")
    fi
    echo ""
fi

# Build for iOS
if [ "$BUILD_IOS" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if bash "$SCRIPT_DIR/build_ios.sh"; then
        ((BUILDS_SUCCESS++))
    else
        ((BUILDS_FAILED++))
        FAILED_PLATFORMS+=("iOS")
    fi
    echo ""
fi

# Build for macOS
if [ "$BUILD_MACOS" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if bash "$SCRIPT_DIR/build_macos.sh"; then
        ((BUILDS_SUCCESS++))
    else
        ((BUILDS_FAILED++))
        FAILED_PLATFORMS+=("macOS")
    fi
    echo ""
fi

# Build for Windows
if [ "$BUILD_WINDOWS" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        if powershell.exe -ExecutionPolicy Bypass -File "$SCRIPT_DIR/build_windows.ps1"; then
            ((BUILDS_SUCCESS++))
        else
            ((BUILDS_FAILED++))
            FAILED_PLATFORMS+=("Windows")
        fi
    else
        echo -e "${YELLOW}Warning: Windows builds must be run on Windows.${NC}"
        echo -e "${YELLOW}Skipping Windows build.${NC}"
        ((BUILDS_SKIPPED++))
        SKIPPED_PLATFORMS+=("Windows")
    fi
    echo ""
fi

# Display build summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Build Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Successful builds: ${GREEN}$BUILDS_SUCCESS${NC}"
echo -e "Failed builds:     ${RED}$BUILDS_FAILED${NC}"
echo -e "Skipped builds:    ${YELLOW}$BUILDS_SKIPPED${NC}"

if [ $BUILDS_SKIPPED -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Skipped platforms:${NC}"
    for platform in "${SKIPPED_PLATFORMS[@]}"; do
        echo -e "  ${YELLOW}⊘${NC} $platform"
    done
fi

if [ $BUILDS_FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed platforms:${NC}"
    for platform in "${FAILED_PLATFORMS[@]}"; do
        echo -e "  ${RED}✗${NC} $platform"
    done
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}All builds completed successfully!${NC}"
echo ""
