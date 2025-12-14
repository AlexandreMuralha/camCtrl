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

# Check if icon files exist
if [ ! -f "$ICON_DIR/${ICON_NAME}.svg" ]; then
    echo -e "${RED}Error: ${ICON_NAME}.svg not found in $ICON_DIR${NC}"
    exit 1
fi

if [ ! -f "$ICON_DIR/${ICON_NAME}.png" ]; then
    echo -e "${YELLOW}Warning: ${ICON_NAME}.png not found. SVG will be used as fallback.${NC}"
fi

# Determine installation paths
if [ "$INSTALL_MODE" = "system" ]; then
    ICON_BASE_DIR="/usr/share/icons/hicolor"
    DESKTOP_DIR="/usr/share/applications"
    UPDATE_CMD="update-desktop-database"
else
    ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
    DESKTOP_DIR="$HOME/.local/share/applications"
    UPDATE_CMD="update-desktop-database"
fi

# Create icon directories
mkdir -p "$ICON_BASE_DIR/scalable/apps"
mkdir -p "$ICON_BASE_DIR/16x16/apps"
mkdir -p "$ICON_BASE_DIR/32x32/apps"
mkdir -p "$ICON_BASE_DIR/48x48/apps"
mkdir -p "$ICON_BASE_DIR/64x64/apps"
mkdir -p "$ICON_BASE_DIR/128x128/apps"
mkdir -p "$ICON_BASE_DIR/256x256/apps"

# Install SVG (scalable icon)
if [ -f "$ICON_DIR/${ICON_NAME}.svg" ]; then
    cp "$ICON_DIR/${ICON_NAME}.svg" "$ICON_BASE_DIR/scalable/apps/${ICON_NAME}.svg"
    echo -e "${GREEN}✓ Installed scalable icon${NC}"
fi

# Install PNG in various sizes
# If PNG exists, copy it and create symlinks/resize as needed
if [ -f "$ICON_DIR/${ICON_NAME}.png" ]; then
    # Copy 256x256 (assuming source is 256x256)
    cp "$ICON_DIR/${ICON_NAME}.png" "$ICON_BASE_DIR/256x256/apps/${ICON_NAME}.png"
    
    # Try to resize for other sizes if ImageMagick or similar is available
    if command -v convert &> /dev/null; then
        convert "$ICON_DIR/${ICON_NAME}.png" -resize 16x16 "$ICON_BASE_DIR/16x16/apps/${ICON_NAME}.png"
        convert "$ICON_DIR/${ICON_NAME}.png" -resize 32x32 "$ICON_BASE_DIR/32x32/apps/${ICON_NAME}.png"
        convert "$ICON_DIR/${ICON_NAME}.png" -resize 48x48 "$ICON_BASE_DIR/48x48/apps/${ICON_NAME}.png"
        convert "$ICON_DIR/${ICON_NAME}.png" -resize 64x64 "$ICON_BASE_DIR/64x64/apps/${ICON_NAME}.png"
        convert "$ICON_DIR/${ICON_NAME}.png" -resize 128x128 "$ICON_BASE_DIR/128x128/apps/${ICON_NAME}.png"
        echo -e "${GREEN}✓ Installed PNG icons in multiple sizes${NC}"
    else
        # If ImageMagick not available, just copy the PNG to 256x256
        echo -e "${YELLOW}ImageMagick not found. Only 256x256 icon installed.${NC}"
        echo -e "${YELLOW}Install ImageMagick for automatic icon resizing.${NC}"
    fi
fi

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

