# CamCtrl Linux Installation Guide

This guide provides detailed instructions for installing CamCtrl on Linux and Raspberry Pi systems.

## Quick Start

**One command installation:**

```bash
curl -fsSL https://raw.githubusercontent.com/AlexandreMuralha/camCtrl/main/installers/linux/install.sh | bash
```

## System Requirements

The following dependencies will be **automatically installed** during the installation process:

- **Python 3.7+** - Will be installed automatically if missing
- **gphoto2** - Command-line tool for camera communication (will be installed automatically if missing)
- **tkinter** - GUI library (usually comes with Python, will be installed if needed)

**Note:** The installer handles all dependency installation automatically. You only need:
- Internet connection
- `sudo` access (for installing system packages)
- A supported Linux distribution (Debian/Ubuntu/Raspberry Pi OS)



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
   - No Python packages required (uses standard library only)

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

## Manual Installation (If Auto-Installation Fails)

If the automatic dependency installation encounters issues, you can manually install the required dependencies before running the installer.

### Install Python 3.7+

**For Debian/Ubuntu/Raspberry Pi OS:**

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv python3-tk
```

**Verify installation:**
```bash
python3 --version  # Should show Python 3.7 or higher
```

### Install gphoto2

**For Debian/Ubuntu/Raspberry Pi OS:**

```bash
sudo apt-get update
sudo apt-get install -y gphoto2
```

**Verify installation:**
```bash
gphoto2 --version  # Should show gphoto2 version
```

### Install tkinter (if missing)

**For Debian/Ubuntu/Raspberry Pi OS:**

```bash
sudo apt-get install -y python3-tk
```

**Verify installation:**
```bash
python3 -c "import tkinter"  # Should run without errors
```

### After Manual Installation

Once all dependencies are manually installed, run the installer again:

```bash
curl -fsSL https://raw.githubusercontent.com/AlexandreMuralha/camCtrl/main/installers/linux/install.sh | bash
```

The installer will detect the existing dependencies and skip the installation step.

**Note:** CamCtrl uses gphoto2 as a command-line tool via subprocess. No Python packages or development headers are required.

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

If Python installation fails, manually install:

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv python3-tk
```

**Verify installation:**
```bash
python3 --version  # Should show Python 3.7 or higher
```

### gphoto2 Not Found

If gphoto2 installation fails, manually install:

```bash
sudo apt-get update
sudo apt-get install -y gphoto2
```

**Verify installation:**
```bash
gphoto2 --version  # Should show gphoto2 version
```

### tkinter Not Found

If tkinter is missing (usually comes with Python):

```bash
sudo apt-get install -y python3-tk
```

**Verify installation:**
```bash
python3 -c "import tkinter"  # Should run without errors
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
curl -fsSL https://raw.githubusercontent.com/AlexandreMuralha/camCtrl/main/installers/linux/uninstall.sh | bash
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

