#!/bin/bash
# Bundle gphoto2 system libraries
# Copies gphoto2 libraries and dependencies to a bundled location

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="$1"  # Target directory for bundled libraries

if [ -z "$BUNDLE_DIR" ]; then
    echo -e "${RED}Error: Target directory for bundled libraries not specified${NC}"
    exit 1
fi

echo "Bundling gphoto2 libraries..."

# Create bundle directory structure
mkdir -p "$BUNDLE_DIR/lib"
LIB_DIR="$BUNDLE_DIR/lib"

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

# Find gphoto2 library locations
# Common locations on Linux
LIB_PATHS=(
    "/usr/lib"
    "/usr/lib/x86_64-linux-gnu"
    "/usr/lib/aarch64-linux-gnu"
    "/usr/lib/arm-linux-gnueabihf"
    "/usr/lib/arm-linux-gnueabi"
    "/usr/local/lib"
)

# Libraries to bundle
GPHOTO2_LIBS=(
    "libgphoto2.so"
    "libgphoto2_port.so"
    "libgphoto2_camera.so"
)

# Dependencies that might be needed
DEP_LIBS=(
    "libusb-1.0.so"
    "libexif.so"
    "libjpeg.so"
)

# Function to find library
find_library() {
    local lib_name="$1"
    for lib_path in "${LIB_PATHS[@]}"; do
        if [ -f "$lib_path/$lib_name" ] || [ -f "$lib_path/$lib_name"* ]; then
            echo "$lib_path"
            return 0
        fi
    done
    return 1
}

# Copy gphoto2 libraries
copied_count=0
for lib in "${GPHOTO2_LIBS[@]}"; do
    lib_path=$(find_library "$lib")
    if [ -n "$lib_path" ]; then
        # Find exact library file (may have version suffix)
        lib_file=$(find "$lib_path" -name "${lib}*" -type f | head -1)
        if [ -n "$lib_file" ]; then
            cp "$lib_file" "$LIB_DIR/"
            echo -e "${GREEN}✓ Copied $(basename "$lib_file")${NC}"
            copied_count=$((copied_count + 1))
        fi
    else
        echo -e "${YELLOW}Warning: $lib not found${NC}"
    fi
done

# Copy dependencies if they exist
for lib in "${DEP_LIBS[@]}"; do
    lib_path=$(find_library "$lib")
    if [ -n "$lib_path" ]; then
        lib_file=$(find "$lib_path" -name "${lib}*" -type f | head -1)
        if [ -n "$lib_file" ]; then
            cp "$lib_file" "$LIB_DIR/"
            echo -e "${GREEN}✓ Copied dependency $(basename "$lib_file")${NC}"
        fi
    fi
done

# Copy gphoto2 camera drivers if they exist
CAMERA_DRIVERS_DIR="/usr/lib/libgphoto2"
if [ -d "$CAMERA_DRIVERS_DIR" ]; then
    mkdir -p "$LIB_DIR/libgphoto2"
    cp -r "$CAMERA_DRIVERS_DIR"/* "$LIB_DIR/libgphoto2/" 2>/dev/null || true
    echo -e "${GREEN}✓ Copied camera drivers${NC}"
fi

# Create a script to set LD_LIBRARY_PATH
cat > "$BUNDLE_DIR/set_library_path.sh" << 'EOF'
#!/bin/bash
# Set LD_LIBRARY_PATH to use bundled libraries
export LD_LIBRARY_PATH="$(dirname "$0")/lib:${LD_LIBRARY_PATH}"
EOF
chmod +x "$BUNDLE_DIR/set_library_path.sh"

if [ $copied_count -gt 0 ]; then
    echo -e "${GREEN}✓ gphoto2 libraries bundled successfully ($copied_count libraries)${NC}"
else
    echo -e "${YELLOW}Warning: No gphoto2 libraries were found to bundle${NC}"
    echo -e "${YELLOW}The system gphoto2 installation will be used instead${NC}"
fi

