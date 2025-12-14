# CamCtrl Installation Guide

This guide provides detailed instructions for installing CamCtrl on Linux and Raspberry Pi systems.

## Quick Start

**Easiest method - one command:**

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/camctrl/main/installers/linux/install.sh | bash
```

## System Requirements

- **Operating System**: Linux (Debian/Ubuntu/Raspberry Pi OS, Fedora, Arch, etc.)
- **Python**: 3.8 or higher
- **gphoto2**: System library for camera communication
- **tkinter**: Usually comes with Python
- **Architecture**: x86_64, arm64, or armv7 (Raspberry Pi)

## Installation Methods

### Method 1: One-Liner Installation (Recommended)

The simplest installation method - downloads and installs everything automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/camctrl/main/installers/linux/install.sh | bash
```

**What happens:**
1. Downloads installer script (~50-100KB)
2. Script automatically downloads application files from GitHub
3. Checks system dependencies
4. Installs missing dependencies via package manager
5. Sets up Python environment
6. Installs application
7. Creates launcher and desktop integration
8. Cleans up temporary files

**No manual steps required!**

### Method 2: Minimal Installer Package

If you prefer to download a package first:

```bash
# Download the minimal installer package
wget https://github.com/yourusername/camctrl/releases/download/v0.4/camctrl-installer.tar.gz

# Extract
tar -xzf camctrl-installer.tar.gz

# Enter directory
cd camctrl-installer

# Run installer
bash install.sh
```

### Method 3: From Source (Development)

For developers or contributors:

```bash
# Clone repository
git clone https://github.com/yourusername/camctrl.git
cd camctrl

# Run installer
bash installers/linux/install.sh
```

## Installation Locations

The installer supports two installation modes:

### User Installation (Default)
- **Application**: `~/.local/share/camctrl/`
- **Launcher**: `~/.local/bin/camctrl`
- **Config**: `~/.config/camctrl/config.py`
- **Icons**: `~/.local/share/icons/hicolor/`
- **Desktop Entry**: `~/.local/share/applications/camctrl.desktop`

### System Installation (Requires sudo)
- **Application**: `/opt/camctrl/`
- **Launcher**: `/usr/local/bin/camctrl`
- **Icons**: `/usr/share/icons/hicolor/`
- **Desktop Entry**: `/usr/share/applications/camctrl.desktop`

The installer automatically detects if you're running as root and uses system-wide installation.

## What Gets Installed

1. **Application Files**
   - `camCtrl.py` - Main application
   - `cam_ops.py` - Camera operations module
   - `config.py` - Configuration template

2. **Python Environment**
   - Virtual environment with all Python dependencies
   - gphoto2 Python package

3. **System Integration**
   - Launcher command (`camctrl`)
   - Desktop entry (menu shortcut)
   - Application icons
   - USB camera permissions (if needed)

## After Installation

### Running the Application

**From Terminal:**
```bash
camctrl
```

**From Applications Menu:**
- Look for "CamCtrl" in Graphics or Photography category
- Click to launch

### Configuration

Edit your configuration:
```bash
nano ~/.config/camctrl/config.py
```

### Captures Location

Default location:
```bash
~/Pictures/camctrl/
```

You can change this in the application interface.

## Dependency Installation

The installer automatically installs missing dependencies:

### Python
- **Debian/Ubuntu/Raspberry Pi OS**: `apt-get install python3 python3-pip python3-venv`
- **Fedora/RHEL**: `yum install python3 python3-pip`
- **Arch**: `pacman -S python python-pip`

### gphoto2
- **Debian/Ubuntu/Raspberry Pi OS**: `apt-get install gphoto2 libgphoto2-dev`
- **Fedora/RHEL**: `yum install gphoto2 libgphoto2-devel`
- **Arch**: `pacman -S gphoto2 libgphoto2`

## Checking Dependencies

Before installation, you can check if all dependencies are installed:

```bash
bash installers/linux/check_dependencies.sh
```

## Troubleshooting

### Installation Fails

1. **Check internet connection**: The installer downloads files from GitHub
2. **Check permissions**: Some steps may require sudo
3. **Check disk space**: Ensure you have at least 500MB free
4. **Check logs**: Look for error messages in the installer output

### Python Not Found

If Python installation fails:
```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install python3 python3-pip python3-venv

# Fedora
sudo yum install python3 python3-pip

# Arch
sudo pacman -S python python-pip
```

### gphoto2 Not Found

If gphoto2 installation fails:
```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install gphoto2 libgphoto2-dev

# Fedora
sudo yum install gphoto2 libgphoto2-devel

# Arch
sudo pacman -S gphoto2 libgphoto2
```

### Icon Not Showing

If the application icon doesn't appear:
```bash
# Update icon cache
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor

# Update desktop database
update-desktop-database ~/.local/share/applications
```

### Launcher Not Found

If `camctrl` command is not found:
1. Check if `~/.local/bin` is in your PATH:
   ```bash
   echo $PATH | grep -q ".local/bin" && echo "OK" || echo "Not in PATH"
   ```
2. Add to PATH (add to `~/.bashrc` or `~/.zshrc`):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```
3. Reload shell:
   ```bash
   source ~/.bashrc
   ```

### Camera Not Detected

1. **Check USB connection**: Unplug and replug camera
2. **Wake camera**: Press shutter button
3. **Close other apps**: Image Capture, Photos, etc.
4. **Check permissions**: Ensure user is in `plugdev` group
5. **Restart application**

### USB Permission Errors

If you get "Could not claim USB device" errors:

1. **Add user to plugdev group**:
   ```bash
   sudo usermod -a -G plugdev $USER
   ```
   (Log out and back in for changes to take effect)

2. **Check udev rules**: The installer should set these up automatically

3. **Try different USB port**

## Uninstallation

To remove CamCtrl:

```bash
bash installers/linux/uninstall.sh
```

Or download and run:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/camctrl/main/installers/linux/uninstall.sh | bash
```

The uninstaller will:
- Remove application files
- Remove launcher
- Remove desktop entry
- Optionally remove icons, config, and captures (you'll be asked)

## Manual Uninstallation

If the uninstaller doesn't work, you can manually remove:

```bash
# Remove application
rm -rf ~/.local/share/camctrl
# or
sudo rm -rf /opt/camctrl

# Remove launcher
rm -f ~/.local/bin/camctrl
# or
sudo rm -f /usr/local/bin/camctrl

# Remove desktop entry
rm -f ~/.local/share/applications/camctrl.desktop
# or
sudo rm -f /usr/share/applications/camctrl.desktop

# Remove config (optional)
rm -rf ~/.config/camctrl
```

## Support

For issues, questions, or contributions:
- [GitHub Issues](https://github.com/yourusername/camctrl/issues)
- [Documentation](https://github.com/yourusername/camctrl)

## Advanced Usage

### Custom Installation Directory

Edit `install.sh` and change `INSTALL_DIR` variable before running.

### Development Installation

For development, you can install in editable mode:

```bash
cd camctrl
python3 -m venv venv
source venv/bin/activate
pip install -r packaging/requirements.txt
python3 camCtrl.py
```

## Building Release Packages

To create release packages:

```bash
bash installers/linux/create_release_package.sh [version]
```

This creates:
- `camctrl-installer-v0.4.tar.gz` - Minimal installer package
- `camctrl-linux-v0.4.tar.gz` - Full release package

Packages are created in `dist/linux/` directory.

