#!/bin/bash
# Icon installation helper script
# Installs application icons to the appropriate system directories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ICON_DIR="$PROJECT_ROOT/assets/icons"

# Installation mode: 'user' or 'system'
INSTALL_MODE="${1:-user}"

# Icon name
ICON_NAME="camctrl"

echo "Installing application icon..."

# Check if SVG icon exists
if [ ! -f "$ICON_DIR/${ICON_NAME}.svg" ]; then
    echo -e "${RED}Error: ${ICON_NAME}.svg not found in $ICON_DIR${NC}"
    exit 1
fi

# Determine installation paths
if [ "$INSTALL_MODE" = "system" ]; then
    ICON_BASE_DIR="/usr/share/icons/hicolor"
    DESKTOP_DIR="/usr/share/applications"
else
    ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
    DESKTOP_DIR="$HOME/.local/share/applications"
fi

# Create scalable icon directory
mkdir -p "$ICON_BASE_DIR/scalable/apps"

# Install SVG (scalable icon - works at any size)
cp "$ICON_DIR/${ICON_NAME}.svg" "$ICON_BASE_DIR/scalable/apps/${ICON_NAME}.svg"
echo -e "${GREEN}✓ Installed scalable icon${NC}"

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_BASE_DIR" 2>/dev/null || true
    echo -e "${GREEN}✓ Updated icon cache${NC}"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    echo -e "${GREEN}✓ Updated desktop database${NC}"
fi

echo -e "${GREEN}Icon installation complete!${NC}"
