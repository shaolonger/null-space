# Build script for Windows native libraries
# Builds Rust core as a DLL for Windows

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "Building Rust core for Windows..." "Green"

# Get the project root directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$RustCoreDir = Join-Path $ProjectRoot "core\null-space-core"
$FlutterAppDir = Join-Path $ProjectRoot "ui\null_space_app"
$OutputDir = Join-Path $FlutterAppDir "windows"

# Check if cargo is installed
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "Error: cargo is not installed. Please install Rust." "Red"
    exit 1
}

# Check if we're on Windows
if (-not ($IsWindows -or $env:OS -like "*Windows*")) {
    Write-ColorOutput "Warning: Windows builds should be performed on Windows." "Yellow"
    Write-ColorOutput "Continuing anyway, but the build may fail..." "Yellow"
}

# Windows target to build for
$Target = "x86_64-pc-windows-msvc"

# Add Windows target if not already installed
Write-ColorOutput "Adding Windows target..." "Green"
Write-Host "Adding target: $Target"
rustup target add $Target

# Check if Visual Studio Build Tools are available
$VSWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $VSWhere) {
    $VSPath = & $VSWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($VSPath) {
        Write-ColorOutput "Visual Studio found at: $VSPath" "Green"
    } else {
        Write-ColorOutput "Warning: Visual Studio C++ Build Tools not found." "Yellow"
        Write-ColorOutput "The build may fail. Please install Visual Studio 2019+ with C++ tools." "Yellow"
    }
} else {
    Write-ColorOutput "Warning: Visual Studio installer not found." "Yellow"
}

# Build for Windows
Set-Location $RustCoreDir

Write-ColorOutput "Building for Windows x64 ($Target)..." "Green"
cargo build --target $Target --release

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Build failed!" "Red"
    exit $LASTEXITCODE
}

# Create output directory
$OutputFrameworksDir = Join-Path $OutputDir "bin\x64"
New-Item -ItemType Directory -Force -Path $OutputFrameworksDir | Out-Null

# Copy the library to the Flutter project
$SourceDll = Join-Path $RustCoreDir "target\$Target\release\null_space_core.dll"
$DestDll = Join-Path $OutputFrameworksDir "null_space_core.dll"

Copy-Item $SourceDll $DestDll -Force

Write-ColorOutput "✓ Built for Windows x64" "Green"
Write-ColorOutput "Windows native library built successfully!" "Green"
Write-ColorOutput "Library is located at: $DestDll" "White"
Write-Host ""
Write-Host "Architecture: x86_64 (64-bit)"
Write-Host "Minimum Windows version: Windows 10"
Write-Host ""
Write-ColorOutput "Note: Ensure Visual C++ Redistributable is installed on target machines." "Yellow"
