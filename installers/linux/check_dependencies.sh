#!/bin/bash
# Dependency checker for CamCtrl
# Checks if all required system dependencies are installed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking system dependencies for CamCtrl..."
echo ""

ALL_OK=true

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
    
    if [ "$PYTHON_MAJOR" -ge 3 ] && ([ "$PYTHON_MAJOR" -gt 3 ] || [ "$PYTHON_MINOR" -ge 7 ]); then
        echo -e "${GREEN}✓ Python $PYTHON_VERSION (OK)${NC}"
    else
        echo -e "${RED}✗ Python $PYTHON_VERSION (Python 3.7+ required)${NC}"
        ALL_OK=false
    fi
else
    echo -e "${RED}✗ Python 3 not found${NC}"
    ALL_OK=false
fi

# Check pip
if command -v pip3 &> /dev/null || python3 -m pip --version &> /dev/null; then
    echo -e "${GREEN}✓ pip (OK)${NC}"
else
    echo -e "${YELLOW}⚠ pip not found (will be installed if needed)${NC}"
fi

# Check gphoto2
if command -v gphoto2 &> /dev/null; then
    GPHOTO2_VERSION=$(gphoto2 --version | head -1 | cut -d' ' -f3)
    echo -e "${GREEN}✓ gphoto2 $GPHOTO2_VERSION (OK)${NC}"
else
    echo -e "${RED}✗ gphoto2 not found${NC}"
    ALL_OK=false
fi

# Check libgphoto2
if ldconfig -p 2>/dev/null | grep -q libgphoto2; then
    echo -e "${GREEN}✓ libgphoto2 library (OK)${NC}"
else
    echo -e "${YELLOW}⚠ libgphoto2 library not found in library path${NC}"
    echo -e "${YELLOW}  (May still work if installed in non-standard location)${NC}"
fi

# Check tkinter (usually comes with Python)
if python3 -c "import tkinter" 2>/dev/null; then
    echo -e "${GREEN}✓ tkinter (OK)${NC}"
else
    echo -e "${YELLOW}⚠ tkinter not found${NC}"
    echo -e "${YELLOW}  Install with: sudo apt-get install python3-tk${NC}"
fi

# Check curl or wget (for installer)
if command -v curl &> /dev/null || command -v wget &> /dev/null; then
    echo -e "${GREEN}✓ curl/wget (OK)${NC}"
else
    echo -e "${YELLOW}⚠ curl or wget not found (needed for installation)${NC}"
fi

echo ""
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}All required dependencies are installed!${NC}"
    exit 0
else
    echo -e "${RED}Some dependencies are missing.${NC}"
    echo -e "${YELLOW}The installer will attempt to install missing dependencies.${NC}"
    exit 1
fi

