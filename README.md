# CamCtrl 0.4

Remote control for DSLR and mirrorless cameras via USB connection. Built with Python and Tkinter, CamCtrl provides an intuitive graphical interface for camera operations using the gphoto2 library.

## Quick Installation (Recommended)

**One-line installation for Linux/Raspberry Pi:**

```bash
curl -fsSL https://raw.githubusercontent.com/AlexandreMuralha/camCtrl/main/installers/linux/install.sh | bash
```

That's it! The installer will automatically:
- Download all necessary files
- Check and install system dependencies (Python, gphoto2)
- Set up the Python environment
- Install the application
- Create launcher command (`camctrl`)
- Set up desktop integration

## Alternative Installation Methods

### Minimal Installer Package

```bash
wget https://github.com/AlexandreMuralha/camCtrl/releases/download/v0.4/camctrl-installer.tar.gz
tar -xzf camctrl-installer.tar.gz
cd camctrl-installer
bash install.sh
```

### From Source (Development)

```bash
git clone https://github.com/AlexandreMuralha/camCtrl.git
cd camctrl
bash installers/linux/install.sh
```

## Requirements

- **Python 3.7+** (will be installed automatically if missing)
- **gphoto2** (will be installed automatically if missing)
- **tkinter** (usually comes with Python)
- **Linux/Raspberry Pi OS** (Debian/Ubuntu-based distributions)

## Usage

After installation, run:

```bash
camctrl
```

Or launch from your Applications menu (Graphics → CamCtrl).

## Features

- **Remote Camera Control**: Control ISO, shutter speed, and aperture
- **Image Capture**: Capture and download images directly to your computer
- **Time-Lapse Photography**: Built-in intervalometer for automated sequences
- **Real-Time Settings Display**: See current camera settings at a glance
- **Cross-Platform Ready**: Architecture supports future Mac and Windows versions

## Interface Sections

- **Capture**: Main capture button with current camera settings display
- **Status**: Real-time status messages and feedback
- **Shutter Speed**: Control panel with buttons for all available speeds
- **Aperture**: Control panel with various f-stop values
- **ISO**: Control panel with ISO sensitivity values
- **Intervalometer**: Automated time-lapse tool with configurable delay
- **Output Path**: Manage where captured images are saved
- **Auto-Open**: Option to automatically open captured images

## Configuration

Settings can be customized by editing:
```
~/.config/camctrl/config.py
```

This file includes:
- Shutter speed mapping (camera values to display format)
- File extensions to look for after capture
- Future configuration options

## Captures

By default, captured images are saved to:
```
~/Pictures/camctrl/
```

You can change this location in the application interface.

## Uninstallation

To uninstall CamCtrl:

```bash
bash installers/linux/uninstall.sh
```

Or if installed via the one-liner method, download the uninstaller:

```bash
curl -fsSL https://raw.githubusercontent.com/AlexandreMuralha/camCtrl/main/installers/linux/uninstall.sh | bash
```

## Troubleshooting

### Camera Not Detected

1. Ensure camera is connected via USB
2. Try unplugging and replugging the camera
3. Press the camera's shutter button to wake it
4. Close any other applications that might be using the camera (Image Capture, Photos, etc.)
5. Restart the application

### USB Connection Errors

The installer includes automatic retry logic for USB connection issues. If problems persist:
- Check USB cable and port
- Try a different USB port
- Restart your computer
- Check camera USB settings

### Permission Issues

If you encounter permission errors:
- Ensure your user is in the appropriate groups (usually `plugdev`)
- Check udev rules are properly installed
- Try running with `sudo` (not recommended for regular use)

## Documentation

For detailed installation instructions and troubleshooting, see:
- [Installation Guide](installers/linux/README.md)

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]

## Support

[Add support/contact information here]

