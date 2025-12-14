"""
Setup configuration for CamCtrl.
This creates a launcher wrapper - it does NOT modify the existing camCtrl.py file.

Copyright (C) 2024 CamCtrl Contributors

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
"""

from setuptools import setup
import os

# Get the project root directory (parent of packaging/)
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

setup(
    name="camctrl",
    version="0.4",
    description="Remote control for DSLR and mirrorless cameras via USB",
    long_description=open(os.path.join(project_root, "README.md")).read() if os.path.exists(os.path.join(project_root, "README.md")) else "",
    long_description_content_type="text/markdown",
    author="CamCtrl Contributors",
    license="GPL-2.0",
    python_requires=">=3.7",
    install_requires=[
        # No external Python dependencies required
        # gphoto2 is used as a command-line tool, not a Python package
        # All required libraries are standard library or system-provided
    ],
    # Note: We don't package the files here - the installer script handles that
    # This setup.py is mainly for creating the launcher command
)

