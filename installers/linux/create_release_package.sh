#!/bin/bash
# Create release packages for CamCtrl
# Creates minimal and full distribution packages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;94m' 
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DIST_DIR="$PROJECT_ROOT/dist/linux"

# Version
VERSION="${1:-0.4}"

echo -e "${BLUE}Creating release packages for CamCtrl v${VERSION}...${NC}"
echo ""

# Create dist directory
mkdir -p "$DIST_DIR"

# Create temporary build directory
BUILD_DIR=$(mktemp -d -t "camctrl-build-XXXXXX")
trap "rm -rf $BUILD_DIR" EXIT

# Minimal package
echo -e "${BLUE}Creating minimal installer package...${NC}"
MINIMAL_DIR="$BUILD_DIR/camctrl-installer"
mkdir -p "$MINIMAL_DIR"

# Copy essential files
cp "$PROJECT_ROOT/camCtrl.py" "$MINIMAL_DIR/"
cp "$PROJECT_ROOT/cam_ops.py" "$MINIMAL_DIR/"
cp "$PROJECT_ROOT/config.py" "$MINIMAL_DIR/"

# Copy installer scripts
mkdir -p "$MINIMAL_DIR/installers/linux"
cp "$PROJECT_ROOT/installers/linux/install.sh" "$MINIMAL_DIR/install.sh"
chmod +x "$MINIMAL_DIR/install.sh"

# Copy common scripts
mkdir -p "$MINIMAL_DIR/installers/common"
cp "$PROJECT_ROOT/installers/common"/*.sh "$MINIMAL_DIR/installers/common/"
chmod +x "$MINIMAL_DIR/installers/common"/*.sh

# Copy icons
mkdir -p "$MINIMAL_DIR/assets/icons"
cp "$PROJECT_ROOT/assets/icons"/* "$MINIMAL_DIR/assets/icons/" 2>/dev/null || true

# Copy packaging files
mkdir -p "$MINIMAL_DIR/packaging"
cp "$PROJECT_ROOT/packaging/requirements.txt" "$MINIMAL_DIR/packaging/"
cp "$PROJECT_ROOT/packaging/setup.py" "$MINIMAL_DIR/packaging/" 2>/dev/null || true
cp "$PROJECT_ROOT/packaging/pyproject.toml" "$MINIMAL_DIR/packaging/" 2>/dev/null || true

# Create basic README
cat > "$MINIMAL_DIR/README.md" << EOF
# CamCtrl Installer Package

## Installation

Run the installer:

\`\`\`bash
bash install.sh
\`\`\`

## Requirements

- Python 3.8+
- gphoto2
- tkinter (usually comes with Python)

The installer will attempt to install missing dependencies automatically.
EOF

# Create tarball
cd "$BUILD_DIR"
tar -czf "$DIST_DIR/camctrl-installer-v${VERSION}.tar.gz" camctrl-installer
echo -e "${GREEN}✓ Created: camctrl-installer-v${VERSION}.tar.gz${NC}"

# Full package (includes everything)
echo -e "${BLUE}Creating full release package...${NC}"
FULL_DIR="$BUILD_DIR/camctrl-linux"
mkdir -p "$FULL_DIR"

# Copy everything except git, dist, venv, cache
rsync -av \
    --exclude='.git' \
    --exclude='dist' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='*.pyo' \
    --exclude='.DS_Store' \
    --exclude='path/to/venv' \
    --exclude='venv' \
    --exclude='*.tar.gz' \
    --exclude='*.deb' \
    "$PROJECT_ROOT/" "$FULL_DIR/"

# Create tarball
cd "$BUILD_DIR"
tar -czf "$DIST_DIR/camctrl-linux-v${VERSION}.tar.gz" camctrl-linux
echo -e "${GREEN}✓ Created: camctrl-linux-v${VERSION}.tar.gz${NC}"

# Show package sizes
echo ""
echo -e "${GREEN}Release packages created:${NC}"
echo -e "  Minimal: ${BLUE}$(du -h "$DIST_DIR/camctrl-installer-v${VERSION}.tar.gz" | cut -f1)${NC} - $(basename "$DIST_DIR/camctrl-installer-v${VERSION}.tar.gz")"
echo -e "  Full:    ${BLUE}$(du -h "$DIST_DIR/camctrl-linux-v${VERSION}.tar.gz" | cut -f1)${NC} - $(basename "$DIST_DIR/camctrl-linux-v${VERSION}.tar.gz")"
echo ""
echo -e "${GREEN}Packages are ready for GitHub Releases!${NC}"
echo -e "Location: ${BLUE}$DIST_DIR${NC}"

