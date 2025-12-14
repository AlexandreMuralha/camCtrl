#!/bin/bash
# CamCtrl Uninstaller Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;94m'
NC='\033[0m' # No Color

APP_NAME="camctrl"

# Detect installation mode
INSTALL_MODE="user"
if [ -d "/opt/${APP_NAME}" ] && [ -w "/opt/${APP_NAME}" ]; then
    INSTALL_MODE="system"
fi

if [ "$INSTALL_MODE" = "system" ]; then
    INSTALL_DIR="/opt/${APP_NAME}"
    BIN_DIR="/usr/local/bin"
    ICON_BASE_DIR="/usr/share/icons/hicolor"
    DESKTOP_DIR="/usr/share/applications"
else
    INSTALL_DIR="$HOME/.local/share/${APP_NAME}"
    BIN_DIR="$HOME/.local/bin"
    ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
    DESKTOP_DIR="$HOME/.local/share/applications"
fi

CONFIG_DIR="$HOME/.config/${APP_NAME}"
CAPTURES_DIR="$HOME/Pictures/${APP_NAME}"

echo -e "${BLUE}CamCtrl Uninstaller${NC}"
echo ""

# Check if installed
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}CamCtrl does not appear to be installed.${NC}"
    exit 0
fi

# Confirm uninstallation
echo -e "This will remove CamCtrl from:"
echo -e "  - ${RED}$INSTALL_DIR${NC}"
echo -e "  - ${RED}$BIN_DIR/${APP_NAME}${NC}"
echo -e "  - ${RED}$DESKTOP_DIR/${APP_NAME}.desktop${NC}"
echo ""
read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Remove application files
echo -e "${BLUE}Removing application files...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✓ Removed application directory${NC}"
fi

# Remove launcher symlink
echo -e "${BLUE}Removing launcher...${NC}"
if [ -L "$BIN_DIR/${APP_NAME}" ] || [ -f "$BIN_DIR/${APP_NAME}" ]; then
    rm -f "$BIN_DIR/${APP_NAME}"
    echo -e "${GREEN}✓ Removed launcher${NC}"
fi

# Remove desktop entry
echo -e "${BLUE}Removing desktop entry...${NC}"
if [ -f "$DESKTOP_DIR/${APP_NAME}.desktop" ]; then
    rm -f "$DESKTOP_DIR/${APP_NAME}.desktop"
    echo -e "${GREEN}✓ Removed desktop entry${NC}"
fi

# Remove icons (optional - ask user)
echo ""
read -p "Remove application icons? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Removing icons...${NC}"
    for size in 16x16 32x32 48x48 64x64 128x128 256x256 scalable; do
        if [ -d "$ICON_BASE_DIR/$size/apps" ]; then
            rm -f "$ICON_BASE_DIR/$size/apps/${APP_NAME}.png" 2>/dev/null || true
            rm -f "$ICON_BASE_DIR/$size/apps/${APP_NAME}.svg" 2>/dev/null || true
        fi
    done
    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$ICON_BASE_DIR" 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ Removed icons${NC}"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

# Ask about config and captures
echo ""
read -p "Remove configuration files? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        echo -e "${GREEN}✓ Removed configuration${NC}"
    fi
fi

echo ""
read -p "Remove captures directory? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$CAPTURES_DIR" ]; then
        rm -rf "$CAPTURES_DIR"
        echo -e "${GREEN}✓ Removed captures directory${NC}"
    fi
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  CamCtrl Uninstallation Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""

