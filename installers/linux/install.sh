#!/bin/bash
# CamCtrl Installation Script
# Standalone installer that can be downloaded via curl and executed
# Automatically downloads application files from GitHub if not present locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="camctrl"
APP_VERSION="0.4"
GITHUB_USER="yourusername"  # Update this with your GitHub username
GITHUB_REPO="camctrl"
GITHUB_BRANCH="main"
GITHUB_BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Installation paths
INSTALL_MODE="user"  # 'user' or 'system'
if [ "$EUID" -eq 0 ]; then
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
    mkdir -p "$BIN_DIR"
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo -e "${YELLOW}Note: Add $HOME/.local/bin to your PATH${NC}"
    fi
fi

CONFIG_DIR="$HOME/.config/${APP_NAME}"
CAPTURES_DIR="$HOME/Pictures/${APP_NAME}"

# Get script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd 2>/dev/null || echo "")"

# Detect if running standalone (via curl) or from repo
STANDALONE=false
if [ ! -f "$PROJECT_ROOT/camCtrl.py" ]; then
    STANDALONE=true
    TEMP_DIR=$(mktemp -d -t "${APP_NAME}-install-XXXXXX")
    PROJECT_ROOT="$TEMP_DIR"
    echo -e "${BLUE}Running in standalone mode. Downloading files from GitHub...${NC}"
fi

# Function to download file from GitHub
download_file() {
    local file_path="$1"
    local target_path="$2"
    local url="${GITHUB_BASE_URL}/${file_path}"
    
    echo "  Downloading $(basename "$file_path")..."
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$target_path" || return 1
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$target_path" || return 1
    else
        echo -e "${RED}Error: curl or wget required but not found${NC}"
        return 1
    fi
}

# Download application files if in standalone mode
if [ "$STANDALONE" = true ]; then
    echo -e "${BLUE}Downloading application files...${NC}"
    mkdir -p "$PROJECT_ROOT"
    mkdir -p "$PROJECT_ROOT/assets/icons"
    mkdir -p "$PROJECT_ROOT/packaging"
    mkdir -p "$PROJECT_ROOT/installers/common"
    
    # Download core application files
    download_file "camCtrl.py" "$PROJECT_ROOT/camCtrl.py"
    download_file "cam_ops.py" "$PROJECT_ROOT/cam_ops.py"
    download_file "config.py" "$PROJECT_ROOT/config.py"
    
    # Download icon files
    download_file "assets/icons/camctrl.svg" "$PROJECT_ROOT/assets/icons/camctrl.svg"
    download_file "assets/icons/camctrl.png" "$PROJECT_ROOT/assets/icons/camctrl.png" || true
    
    # Download packaging files
    download_file "packaging/requirements.txt" "$PROJECT_ROOT/packaging/requirements.txt"
    
    # Download common scripts
    download_file "installers/common/bundle_dependencies.sh" "$PROJECT_ROOT/installers/common/bundle_dependencies.sh"
    download_file "installers/common/bundle_gphoto2.sh" "$PROJECT_ROOT/installers/common/bundle_gphoto2.sh"
    download_file "installers/common/install_icon.sh" "$PROJECT_ROOT/installers/common/install_icon.sh"
    
    chmod +x "$PROJECT_ROOT/installers/common"/*.sh
    
    echo -e "${GREEN}✓ Files downloaded${NC}"
fi

# Check dependencies
echo -e "${BLUE}Checking system dependencies...${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Python 3 not found. Attempting to install...${NC}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-venv
    elif command -v yum &> /dev/null; then
        sudo yum install -y python3 python3-pip
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm python python-pip
    else
        echo -e "${RED}Error: Could not install Python. Please install Python 3.8+ manually.${NC}"
        exit 1
    fi
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 8 ]); then
    echo -e "${RED}Error: Python 3.8+ required. Found Python $PYTHON_VERSION${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"

# Check gphoto2
if ! command -v gphoto2 &> /dev/null; then
    echo -e "${YELLOW}gphoto2 not found. Attempting to install...${NC}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y gphoto2 libgphoto2-dev
    elif command -v yum &> /dev/null; then
        sudo yum install -y gphoto2 libgphoto2-devel
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm gphoto2 libgphoto2
    else
        echo -e "${RED}Error: Could not install gphoto2. Please install it manually.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ gphoto2 found${NC}"

# Create installation directory
echo -e "${BLUE}Creating installation directory...${NC}"
sudo mkdir -p "$INSTALL_DIR" 2>/dev/null || mkdir -p "$INSTALL_DIR"
sudo chown "$USER:$USER" "$INSTALL_DIR" 2>/dev/null || true

# Copy application files
echo -e "${BLUE}Installing application files...${NC}"
cp "$PROJECT_ROOT/camCtrl.py" "$INSTALL_DIR/"
cp "$PROJECT_ROOT/cam_ops.py" "$INSTALL_DIR/"
cp "$PROJECT_ROOT/config.py" "$INSTALL_DIR/"

# Create Python virtual environment
echo -e "${BLUE}Setting up Python environment...${NC}"
VENV_DIR="$INSTALL_DIR/venv"
"$PROJECT_ROOT/installers/common/bundle_dependencies.sh" "$VENV_DIR"

# Bundle gphoto2 libraries (optional, system libraries will be used if bundling fails)
echo -e "${BLUE}Bundling gphoto2 libraries...${NC}"
LIB_DIR="$INSTALL_DIR/libs"
"$PROJECT_ROOT/installers/common/bundle_gphoto2.sh" "$LIB_DIR" || echo -e "${YELLOW}Warning: Library bundling failed, using system libraries${NC}"

# Create launcher script
echo -e "${BLUE}Creating launcher...${NC}"
LAUNCHER_SCRIPT="$INSTALL_DIR/${APP_NAME}"
cat > "$LAUNCHER_SCRIPT" << EOF
#!/bin/bash
# CamCtrl Launcher Script

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Set library path if bundled libraries exist
if [ -d "$LIB_DIR/lib" ]; then
    export LD_LIBRARY_PATH="$LIB_DIR/lib:\${LD_LIBRARY_PATH}"
fi

# Change to installation directory
cd "$INSTALL_DIR"

# Run the application
exec python3 camCtrl.py "\$@"
EOF
chmod +x "$LAUNCHER_SCRIPT"

# Create symlink in bin directory
echo -e "${BLUE}Creating command symlink...${NC}"
mkdir -p "$BIN_DIR"
ln -sf "$LAUNCHER_SCRIPT" "$BIN_DIR/${APP_NAME}"

# Install icons
echo -e "${BLUE}Installing application icon...${NC}"
"$PROJECT_ROOT/installers/common/install_icon.sh" "$INSTALL_MODE"

# Create desktop entry
echo -e "${BLUE}Creating desktop entry...${NC}"
mkdir -p "$DESKTOP_DIR"
DESKTOP_FILE="$DESKTOP_DIR/${APP_NAME}.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=CamCtrl
Comment=Remote control for DSLR and mirrorless cameras
Exec=$BIN_DIR/${APP_NAME}
Icon=${APP_NAME}
Terminal=false
Type=Application
Categories=Graphics;Photography;
StartupNotify=true
EOF
chmod +x "$DESKTOP_FILE"

# Create config directory and copy config
echo -e "${BLUE}Setting up configuration...${NC}"
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config.py" ]; then
    cp "$PROJECT_ROOT/config.py" "$CONFIG_DIR/config.py"
fi

# Create captures directory
mkdir -p "$CAPTURES_DIR"

# Clean up temporary files if in standalone mode
if [ "$STANDALONE" = true ]; then
    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"
fi

# Success message
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  CamCtrl Installation Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "Application installed to: ${BLUE}$INSTALL_DIR${NC}"
echo -e "Configuration: ${BLUE}$CONFIG_DIR/config.py${NC}"
echo -e "Captures: ${BLUE}$CAPTURES_DIR${NC}"
echo ""
echo -e "Run ${GREEN}${APP_NAME}${NC} from terminal or launch from Applications menu"
echo ""

