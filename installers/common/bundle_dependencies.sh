#!/bin/bash
# Bundle Python dependencies into a virtual environment
# This creates a standalone Python environment with all required packages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PACKAGING_DIR="$PROJECT_ROOT/packaging"
VENV_DIR="$1"  # Target directory for venv

if [ -z "$VENV_DIR" ]; then
    echo -e "${RED}Error: Target directory for venv not specified${NC}"
    exit 1
fi

echo "Bundling Python dependencies..."

# Check if requirements.txt exists
if [ ! -f "$PACKAGING_DIR/requirements.txt" ]; then
    echo -e "${RED}Error: requirements.txt not found in $PACKAGING_DIR${NC}"
    exit 1
fi

# Create virtual environment
echo "Creating virtual environment in $VENV_DIR..."
python3 -m venv "$VENV_DIR"

# Activate virtual environment and install dependencies
echo "Installing Python packages..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
pip install --upgrade pip --quiet

# Set PKG_CONFIG_PATH if needed (helps pkg-config find libraries)
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/lib/pkgconfig:/usr/lib/arm-linux-gnueabihf/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"

# Verify pkg-config can find libgphoto2 before attempting install
if ! pkg-config --exists libgphoto2 2>/dev/null; then
    echo "Warning: pkg-config cannot find libgphoto2. Installation may fail."
    echo "Make sure libgphoto2-dev is installed: sudo apt-get install -y libgphoto2-dev pkg-config"
fi

# Install requirements
# Try to use pre-built wheels first (especially for Raspberry Pi)
# If that fails, it will fall back to building from source
echo "Installing gphoto2 Python package (this may take a few minutes)..."
if ! pip install -r "$PACKAGING_DIR/requirements.txt"; then
    echo ""
    echo "Error: Failed to install Python packages."
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Make sure development packages are installed:"
    echo "   sudo apt-get install -y libgphoto2-dev pkg-config python3-dev build-essential"
    echo ""
    echo "2. Verify pkg-config can find libgphoto2:"
    echo "   pkg-config --modversion libgphoto2"
    echo ""
    echo "3. If that fails, try:"
    echo "   sudo ldconfig"
    echo "   pkg-config --modversion libgphoto2"
    exit 1
fi

echo -e "${GREEN}✓ Python dependencies bundled successfully${NC}"

