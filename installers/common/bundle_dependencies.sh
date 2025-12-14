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

# Install requirements
pip install -r "$PACKAGING_DIR/requirements.txt"

echo -e "${GREEN}✓ Python dependencies bundled successfully${NC}"

