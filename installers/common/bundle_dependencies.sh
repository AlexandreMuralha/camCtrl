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

# Check if there are any actual dependencies (not just comments)
# Remove comments and empty lines, check if anything remains
HAS_DEPS=$(grep -v '^#' "$PACKAGING_DIR/requirements.txt" | grep -v '^$' | wc -l)

if [ "$HAS_DEPS" -eq 0 ]; then
    echo -e "${GREEN}No Python dependencies required - using standard library only${NC}"
    echo -e "${GREEN}✓ Python environment ready (no packages to install)${NC}"
    # Still create a minimal venv for consistency, but don't install anything
    python3 -m venv "$VENV_DIR" --without-pip 2>/dev/null || python3 -m venv "$VENV_DIR"
else
    # Create virtual environment
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
    
    # Activate virtual environment and install dependencies
    echo "Installing Python packages..."
    source "$VENV_DIR/bin/activate"
    
    # Upgrade pip
    pip install --upgrade pip --quiet
    
    # Install requirements
    echo "Installing Python packages from requirements.txt..."
    if ! pip install -r "$PACKAGING_DIR/requirements.txt"; then
        echo ""
        echo "Error: Failed to install Python packages."
        exit 1
    fi
    
    echo -e "${GREEN}✓ Python dependencies bundled successfully${NC}"
fi

