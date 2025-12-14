# CamCtrl 0.4

CamCtrl is a desktop interface control for digital cameras via USB connection. Built with Python and Tkinter, CamCtrl provides an intuitive graphical interface for camera operations using the gphoto2 library. It is particularly suitable for astrophotography or other captures that require time-lapse photography and controlling the camera from a desktop environment.

## Quick Installation (Recommended)

**One-line installation for Linux/Raspberry Pi:**

```bash
curl -fsSL https://raw.githubusercontent.com/AlexandreMuralha/camCtrl/main/installers/linux/install.sh | bash
```

For detailed installation instructions, see the [Installation Guide](installers/linux/INSTALL.md).


## Usage

After installation, run:

```bash
camctrl
```

Or launch from your Applications menu (Graphics → CamCtrl).


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
- Try running with `sudo`

## Documentation

For detailed installation instructions and troubleshooting, see:
- [Installation Guide](installers/linux/INSTALL.md)

## License

CamCtrl is licensed under the **GNU General Public License v2.0 (GPL-2.0)**.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

See [LICENSE](LICENSE) file for the full license text.

### Third-Party Software

This program uses **gphoto2**, which is licensed under GPL-2.0. gphoto2 is a command-line frontend to libgphoto2. For more information, visit: http://www.gphoto.org/


## Contributing



## Support



