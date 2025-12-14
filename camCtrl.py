import tkinter as tk
from tkinter import scrolledtext, ttk, Spinbox, LabelFrame, filedialog
import subprocess
import os
import time
import threading
import ast
from cam_ops import (
    detect_camera as cam_detect_camera,
    get_camera_settings,
    set_iso as cam_set_iso,
    set_shutter_speed as cam_set_shutter_speed,
    set_aperture as cam_set_aperture,
    capture_image as cam_capture_image,
    list_files as cam_list_files,
    download_files as cam_download_files,
)
import webbrowser

success_color = "green"

# Default shutter speed mapping (fallback if config file is missing or invalid)
default_shutter_speed_mapping = {
    "0.5000s": "1/2",
    "0.3333s": "1/3",
    "0.2500s": "1/4",
    "0.2000s": "1/5",
    "0.1666s": "1/6",
    "0.1250s": "1/8",
    "0.1000s": "1/10",
    "0.0666s": "1/15",
    "0.0500s": "1/20",
    "0.0333s": "1/30",
    "0.0250s": "1/40",
    "0.0166s": "1/60",
    "0.0111s": "1/90",
    "0.0100s": "1/100",
    "0.0080s": "1/125",
    "0.0063s": "1/160",
    "0.0050s": "1/200",
    "0.0040s": "1/250",
    "0.0031s": "1/320",
    "0.0025s": "1/400",
    "0.0020s": "1/500",
    "0.0016s": "1/640",
    "0.0013s": "1/800",
    "0.0010s": "1/1000",
    "0.0008s": "1/1250",
    "0.0006s": "1/1600",
    "0.0005s": "1/2000",
    "0.0004s": "1/2500",
    "0.0003s": "1/3200",
    "0.0002s": "1/4000",
    "1.0000s": '1"',
    "1.5000s": '1.5"',
    "2.0000s": '2"',
    "3.0000s": '3"',
    "4.0000s": '4"',
    "5.0000s": '5"',
    "6.0000s": '6"',
    "8.0000s": '8"',
    "10.0000s": '10"',
    "15.0000s": '15"',
    "20.0000s": '20"',
    "25.0000s": '25"',
    "30.0000s": '30"',
}

# Default file extensions to look for after capture
default_file_extensions = [".jpg", ".nef", ".cr2", ".arw", ".raf", ".orf", ".rw2", ".dng", ".3fr", ".pef", ".tif", ".tiff", ".fits", ".fit"]


def load_config():
    """Load configuration from config.py file. Creates default file if missing."""
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, "config.py")
    
    # Default config content
    default_config_content = '''# Camera Control Configuration
# Edit this file to customize camera settings

# Shutter speed mapping for display
# Maps camera values (keys) to display values (values)
shutter_speed_mapping = {
    "0.5000s": "1/2",
    "0.3333s": "1/3",
    "0.2500s": "1/4",
    "0.2000s": "1/5",
    "0.1666s": "1/6",
    "0.1250s": "1/8",
    "0.1000s": "1/10",
    "0.0666s": "1/15",
    "0.0500s": "1/20",
    "0.0333s": "1/30",
    "0.0250s": "1/40",
    "0.0166s": "1/60",
    "0.0111s": "1/90",
    "0.0100s": "1/100",
    "0.0080s": "1/125",
    "0.0063s": "1/160",
    "0.0050s": "1/200",
    "0.0040s": "1/250",
    "0.0031s": "1/320",
    "0.0025s": "1/400",
    "0.0020s": "1/500",
    "0.0016s": "1/640",
    "0.0013s": "1/800",
    "0.0010s": "1/1000",
    "0.0008s": "1/1250",
    "0.0006s": "1/1600",
    "0.0005s": "1/2000",
    "0.0004s": "1/2500",
    "0.0003s": "1/3200",
    "0.0002s": "1/4000",
    "1.0000s": '1"',
    "1.5000s": '1.5"',
    "2.0000s": '2"',
    "3.0000s": '3"',
    "4.0000s": '4"',
    "5.0000s": '5"',
    "6.0000s": '6"',
    "8.0000s": '8"',
    "10.0000s": '10"',
    "15.0000s": '15"',
    "20.0000s": '20"',
    "25.0000s": '25"',
    "30.0000s": '30"',
}

# File extensions to look for after capture
# Add extensions for your camera's RAW format if needed
# Common formats: .nef (Nikon), .cr2 (Canon), .arw (Sony), .raf (Fuji), 
#                 .orf (Olympus), .rw2 (Panasonic), .dng (Adobe/Leica), 
#                 .3fr (Hasselblad), .pef (Pentax/Ricoh)
# Professional/Astro: .tif, .tiff, .fits, .fit
file_extensions = [".jpg", ".nef", ".cr2", ".arw", ".raf", ".orf", ".rw2", ".dng", ".3fr", ".pef", ".tif", ".tiff", ".fits", ".fit"]

'''
    
    # Create config file if it doesn't exist
    if not os.path.exists(config_path):
        try:
            with open(config_path, 'w') as f:
                f.write(default_config_content)
        except Exception as e:
            print(f"Warning: Could not create config file: {e}")
            return {
                "shutter_speed_mapping": default_shutter_speed_mapping,
                "file_extensions": default_file_extensions
            }
    
    # Load config from file
    try:
        # Create a restricted namespace for safe execution
        config_namespace = {}
        with open(config_path, 'r') as f:
            config_code = f.read()
        exec(compile(config_code, config_path, 'exec'), config_namespace)
        
        # Extract config values from the namespace
        config = {
            "shutter_speed_mapping": config_namespace.get(
                "shutter_speed_mapping", default_shutter_speed_mapping
            ),
            "file_extensions": config_namespace.get(
                "file_extensions", default_file_extensions
            )
        }
        return config
    except Exception as e:
        print(f"Warning: Error loading config file: {e}. Using defaults.")
        return {
            "shutter_speed_mapping": default_shutter_speed_mapping,
            "file_extensions": default_file_extensions
        }


# Load configuration at startup
config = load_config()
shutter_speed_mapping = config.get("shutter_speed_mapping", default_shutter_speed_mapping)
file_extensions = config.get("file_extensions", default_file_extensions)

# default save path
save_path = os.path.join(os.getcwd(), "captures")
os.makedirs(save_path, exist_ok=True)
delay = 1.0  # default
auto_open_images = False  # Auto-open captured images


def update_camera_settings_to_show():
    """Update UI with current camera settings."""
    settings = get_camera_settings(shutter_speed_mapping)
    
    # Handle errors
    if settings["errors"]:
        for error in settings["errors"]:
            status_label.config(text=error, fg="red")
        return
    
    # Update ISO
    if settings["iso"]:
        iso_var.set(settings["iso"])
        iso_message.config(text=f"ISO: {settings['iso']}")
    
    # Update Shutter
    if settings["shutter"]:
        shutter_var.set(settings["shutter"]["value"])
        shutter_message.config(text=f"Shutter Speed: {settings['shutter']['display']}")
    
    # Update Aperture
    if settings["aperture"]:
        aperture_var.set(settings["aperture"])
        aperture_message.config(text=f"Aperture: {settings['aperture']}")


def set_delay():
    global delay
    try:
        delay = float(delay_spinbox.get())
    except ValueError:
        status_label.config(text="Invalid input for delay.", fg="red")
        delay = 1.0


def set_delay_value(value):
    delay_spinbox.delete(0, tk.END)
    delay_spinbox.insert(0, str(value))
    set_delay()


def set_iso(value):
    """Wrapper for setting ISO with UI callbacks."""
    def status_cb(msg, color):
        status_label.config(text=msg, fg=color)
    
    cam_set_iso(value, status_callback=status_cb, update_callback=update_camera_settings_to_show)


def set_shutter_speed(value):
    """Wrapper for setting shutter speed with UI callbacks."""
    def status_cb(msg, color):
        status_label.config(text=msg, fg=color)
    
    cam_set_shutter_speed(value, status_callback=status_cb, update_callback=update_camera_settings_to_show)


def set_aperture(value):
    """Wrapper for setting aperture with UI callbacks."""
    def status_cb(msg, color):
        status_label.config(text=msg, fg=color)
    
    cam_set_aperture(value, status_callback=status_cb, update_callback=update_camera_settings_to_show)


def capture_image_worker():
    """Worker function for capturing image in a thread."""
    def status_cb(msg, color):
        status_label.config(text=msg, fg=color)
    status_label.update_idletasks()

    def output_cb(text):
        if text == "":  # Clear output
            output_text.delete(1.0, tk.END)
        else:
            output_text.insert(tk.END, text)
    
    files_saved = cam_capture_image(
        save_path,
        file_extensions,
        status_callback=status_cb,
        output_callback=output_cb,
    )
    
    # Auto-open image if enabled
    if auto_open_images and files_saved:
        # Prefer JPG over RAW if both exist
        jpg_files = [f for f in files_saved if f.lower().endswith('.jpg')]
        if jpg_files:
            open_image_file(jpg_files[0])
        elif files_saved:
            # Open the first file (RAW)
            open_image_file(files_saved[0])


def capture_image():
    """Start image capture in a separate thread."""
    t = threading.Thread(target=capture_image_worker, daemon=True)
    t.start()


def list_files():
    """List files on camera."""
    def output_cb(text):
        if text == "":  # Clear output
            output_text.delete(1.0, tk.END)
        else:
            output_text.insert(tk.END, text)
    
    def status_cb(msg, color):
        status_label.config(text=msg, fg=color)
    
    cam_list_files(output_callback=output_cb, status_callback=status_cb)


def download_files():
    """Download all files from camera."""
    def output_cb(text):
        if text == "":  # Clear output
            output_text.delete(1.0, tk.END)
        else:
            output_text.insert(tk.END, text)
    
    def status_cb(msg, color):
        status_label.config(text=msg, fg=color)
    
    cam_download_files(output_callback=output_cb, status_callback=status_cb)


def start_time_lapse_worker():
    try:
        shots = int(time_lapse_spinbox.get())
        set_delay()
        for _ in range(shots):
            capture_image_worker()
            if "Error:" in status_label.cget("text"):
                break
            time.sleep(delay)
    except ValueError:
        status_label.config(text="Invalid input for time lapse.", fg="red")


def start_time_lapse():
    t = threading.Thread(target=start_time_lapse_worker, daemon=True)
    t.start()


def detect_camera():
    """Detect connected camera."""
    def output_cb(text):
        output_text.insert(tk.END, text)
    
    def status_cb(msg, color):
        status_label.config(text=msg, fg=color)
    
    cam_detect_camera(output_callback=output_cb, status_callback=status_cb)


def select_output_folder():
    global save_path
    folder_selected = filedialog.askdirectory()
    if folder_selected:
        save_path = folder_selected
        output_path_label.config(text=f"{save_path}")


def open_output_folder():
    if os.path.isdir(save_path):
        if os.name == "nt":
            subprocess.Popen(["explorer", save_path])
        elif hasattr(os, "uname") and os.uname().sysname == "Darwin":
            subprocess.Popen(["open", save_path])
        else:
            subprocess.Popen(["xdg-open", save_path])


def open_image_file(filepath):
    """Open an image file with the system's default application."""
    if os.path.isfile(filepath):
        if os.name == "nt":
            subprocess.Popen(["start", filepath], shell=True)
        elif hasattr(os, "uname") and os.uname().sysname == "Darwin":
            subprocess.Popen(["open", filepath])
        else:
            subprocess.Popen(["xdg-open", filepath])


def toggle_auto_open():
    """Toggle auto-open images feature."""
    global auto_open_images
    auto_open_images = not auto_open_images
    
    if auto_open_images:
        auto_open_button.config(text="Auto Open", fg="green", activeforeground="green")
    else:
        auto_open_button.config(text="Auto Open", fg="gray", activeforeground="gray")


# GUI
root = tk.Tk()
root.title("CamCtrl 0.4")
root.geometry("940x640")
root.resizable(False, False)

tabs = ttk.Notebook(root)
tab_control = ttk.Frame(tabs)
tab_output = ttk.Frame(tabs)
tab_info = ttk.Frame(tabs)
tabs.add(tab_control, text="Control")
tabs.add(tab_output, text="CLI Output")
tabs.add(tab_info, text="Info")
tabs.grid(row=0, column=0, sticky="nsew")

root.grid_rowconfigure(0, weight=1)
root.grid_columnconfigure(0, weight=1)

# frames top
frames_container = tk.Frame(tab_control)
frames_container.grid(row=0, column=0, padx=5, pady=5, sticky="nsew")
tab_control.grid_rowconfigure(0, weight=1)
tab_control.grid_columnconfigure(0, weight=1)

capture_frame = LabelFrame(frames_container, text="Capture", height=70)
capture_frame.grid(row=0, column=0, padx=5, pady=5, sticky="nsew")
capture_frame.grid_propagate(False)

status_frame = LabelFrame(frames_container, text="Status", height=70)
status_frame.grid(row=0, column=1, padx=5, pady=5, sticky="nsew")
status_frame.grid_propagate(False)

frames_container.grid_rowconfigure(0, weight=1)
frames_container.grid_columnconfigure(0, weight=1)
frames_container.grid_columnconfigure(1, weight=1)

status_label = tk.Message(
    status_frame,
    text="...",
    fg="green",
    anchor="w",
    justify="left",
    width=300,
    aspect=100,
)
status_label.grid(row=0, column=0, sticky="nsew")

capture_button = tk.Button(
    capture_frame, text="Capture", command=capture_image, width=20, height=4,
    font=("Arial", 10, "bold"),
)
capture_button.grid(row=0, column=0, rowspan=3, padx=2, pady=2)

iso_var = tk.StringVar(value="-")
shutter_var = tk.StringVar(value="-")
aperture_var = tk.StringVar(value="f-")

iso_message = tk.Message(capture_frame, text=f"ISO: {iso_var.get()}", width=350)
iso_message.grid(row=0, column=1, padx=2, pady=2, sticky="n")

shutter_message = tk.Message(
    capture_frame, text=f"Shutter Speed: {shutter_var.get()}", width=350
)
shutter_message.grid(row=1, column=1, padx=2, pady=2, sticky="n")

aperture_message = tk.Message(
    capture_frame, text=f"Aperture: {aperture_var.get()}", width=350
)
aperture_message.grid(row=2, column=1, padx=2, pady=2, sticky="n")

# Shutter frame
shutter_labelframe = LabelFrame(tab_control, text="Shutter speed")
shutter_labelframe.grid(row=1, column=0, pady=5, padx=5, sticky="nsew")

shutter_frame = tk.Frame(shutter_labelframe)
shutter_frame.grid(row=0, column=0, pady=5, sticky="nsew")

for index, value in enumerate(
    ['30"', '20"', '15"', '10"', '8"', '6"', '4"', '3"', '2"', '1.5"', '1"', "1/2", "1/3"]
):
    btn = tk.Button(shutter_frame, text=value, command=lambda v=value: set_shutter_speed(v), width=3)
    btn.grid(row=0, column=index, padx=1)

for index, value in enumerate(
    ["1/4", "1/6", "1/8", "1/15", "1/30", "1/60", "1/90", "1/125", "1/250", "1/500", "1/1000", "1/2000", "1/4000"]
):
    btn = tk.Button(shutter_frame, text=value, command=lambda v=value: set_shutter_speed(v), width=3)
    btn.grid(row=1, column=index, padx=1)

# Aperture frame
aperture_labelframe = LabelFrame(tab_control, text="Aperture")
aperture_labelframe.grid(row=2, column=0, pady=5, padx=5, sticky="nsew")

aperture_frame = tk.Frame(aperture_labelframe)
aperture_frame.grid(row=0, column=0, pady=5, sticky="nsew")

for index, value in enumerate(
    ["f/1.4", "f/1.8", "f/2.8", "f/3.5", "f/4", "f/4.8", "f/5.6", "f/6.7", "f/8", "f/11", "f/13", "f/16", "f/22"]
):
    btn = tk.Button(aperture_frame, text=value, command=lambda v=value: set_aperture(v), width=2)
    btn.grid(row=0, column=index, padx=1)

# ISO frame
iso_labelframe = LabelFrame(tab_control, text="ISO")
iso_labelframe.grid(row=3, column=0, pady=5, padx=5, sticky="nsew")

iso_frame = tk.Frame(iso_labelframe)
iso_frame.grid(row=0, column=0, pady=5, sticky="nsew")

for index, value in enumerate([100, 200, 400, 800, 1600, 3200, 6400]):
    btn = tk.Button(iso_frame, text=f"ISO {value}", command=lambda v=value: set_iso(v), width=5)
    btn.grid(row=0, column=index, padx=2)

# Intervalometer
time_lapse_labelframe = LabelFrame(tab_control, text="Intervalometer")
time_lapse_labelframe.grid(row=4, column=0, pady=5, padx=5, sticky="nsew")

time_lapse_frame = tk.Frame(time_lapse_labelframe)
time_lapse_frame.grid(row=0, column=0, pady=5, sticky="nsew")

time_lapse_label = tk.Label(time_lapse_frame, text="Number of captures")
time_lapse_label.grid(row=0, column=0, padx=5)

time_lapse_spinbox = Spinbox(time_lapse_frame, from_=1, to=100, width=5)
time_lapse_spinbox.grid(row=0, column=1)

time_lapse_button = tk.Button(
    time_lapse_frame, text="Start", command=start_time_lapse, width=20
)
time_lapse_button.grid(row=0, column=2, padx=5)

# Delay
delay_frame = tk.Frame(time_lapse_labelframe)
delay_frame.grid(row=1, column=0, pady=5, sticky="nsew")

delay_label = tk.Label(delay_frame, text="Delay (sec)")
delay_label.grid(row=0, column=0, padx=5)

delay_spinbox = Spinbox(delay_frame, from_=1, to=60, increment=0.5, width=5)
delay_spinbox.grid(row=0, column=1)

delay_buttons_frame = tk.Frame(delay_frame)
delay_buttons_frame.grid(row=0, column=2, padx=5)

for index, (text, value) in enumerate([("3s", 3), ("5s", 5), ("10s", 10), ("20s", 20)]):
    btn = tk.Button(delay_buttons_frame, text=text, command=lambda v=value: set_delay_value(v), width=5)
    btn.grid(row=0, column=index, padx=2)

# Output path
output_path_labelframe = LabelFrame(tab_control, text="Output path")
output_path_labelframe.grid(row=5, column=0, pady=5, padx=5, sticky="nsew")

output_path_frame = tk.Frame(output_path_labelframe)
output_path_frame.grid(row=5, column=0, pady=5, sticky="nsew")
output_path_frame.grid_columnconfigure(0, weight=1)  # Make column 0 expandable

output_path_label = tk.Label(output_path_frame, text=f"{save_path}", anchor="w")
output_path_label.grid(row=0, column=0, padx=5, sticky="w")

select_folder_button = tk.Button(
    output_path_frame, text="Change", command=select_output_folder
)
select_folder_button.grid(row=0, column=1, padx=5)

open_folder_button = tk.Button(
    output_path_frame, text="Open", command=open_output_folder
)
open_folder_button.grid(row=0, column=2, padx=5)

auto_open_button = tk.Button(
    output_path_frame, text="Auto Open", command=toggle_auto_open, fg="gray"
)
auto_open_button.grid(row=0, column=3, padx=5, sticky="e")

# TAB 2
output_text = scrolledtext.ScrolledText(tab_output, wrap=tk.WORD, width=80, height=20)
output_text.grid(row=0, column=0, padx=5, pady=5, sticky="nsew")

tab_output.grid_rowconfigure(0, weight=1)
tab_output.grid_columnconfigure(0, weight=1)

# TAB 3
info_text = """CamCtrl 0.4

OVERVIEW
CamCtrl is a cross-platform desktop UI application for remote control of DSLR and mirrorless cameras via USB connection. Built with Python and Tkinter, it provides an intuitive graphical interface for camera operations using the gphoto2 library.

INTERFACE SECTIONS
• Capture - The main capture button allows you to take a single photograph. The current camera settings (ISO, shutter speed, and aperture) are displayed next to the button for quick reference.
• Status - Shows status messages and feedback from camera operations.
• Shutter Speed -  Control panel with buttons for all available shutter speeds.
• Aperture: Control panel with buttons for various aperture values (f-stops) from f/1.4 to f/22.
• ISO: Control panel with buttons for ISO sensitivity values.
• Intervalometer: Automated time-lapse photography tool. Set the number of captures (1-100) and the delay between shots (1-60 seconds). Use preset delay buttons (3s, 5s, 10s, 20s) or enter a custom value. Click "Start" to begin the sequence.
• Output Path: Manage where captured images are saved. The "Auto Open" button toggles automatic opening of captured images in your default viewer.

REQUIREMENTS
• gphoto2: Required for camera communication
  Download: http://www.gphoto.org/
  Installation:
  - macOS: brew install gphoto2
  - Linux: sudo apt-get install gphoto2 (or use your distribution's package manager)
  - Windows: Download from gphoto2 website

CONFIGURATION
Settings can be customized by editing the config.py file in the application directory."""
info_label = tk.Text(
    tab_info,
    wrap=tk.WORD,
    font=("Arial", 10),
    padx=10,
    pady=10,
    state="disabled",
    relief=tk.SOLID,
    bd=1,
    highlightthickness=0,
)
info_label.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
tab_info.grid_rowconfigure(0, weight=1)
tab_info.grid_columnconfigure(0, weight=1)

# Configure link tag
info_label.tag_configure("link", foreground="blue", underline=1)
info_label.tag_bind("link", "<Button-1>", lambda e: webbrowser.open("http://www.gphoto.org/"))
info_label.tag_bind("link", "<Enter>", lambda e: info_label.config(cursor="hand2"))
info_label.tag_bind("link", "<Leave>", lambda e: info_label.config(cursor=""))

# Insert text with clickable link
info_label.config(state="normal")
# Split text at the URL
url = "http://www.gphoto.org/"
parts = info_text.split(url)
info_label.insert(tk.END, parts[0])
info_label.insert(tk.END, url, "link")
if len(parts) > 1:
    info_label.insert(tk.END, parts[1])
info_label.config(state="disabled")

# Exit
exit_button = tk.Button(root, text="Exit", command=root.quit, width=10)
exit_button.grid(row=1, column=0, sticky="se", padx=5, pady=5)

# opcional: carregar configurações ao iniciar
update_camera_settings_to_show()

root.mainloop()
