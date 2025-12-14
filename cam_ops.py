"""Camera operations module for gphoto2 commands."""

import subprocess
from datetime import datetime
import os
import glob
import time


def detect_camera(output_callback=None, status_callback=None):
    """
    Detect connected camera using gphoto2.
    
    Args:
        output_callback: Function to call with stdout/stderr output
        status_callback: Function(status_message, color) to update status
    """
    p = subprocess.Popen(
        ["gphoto2", "--auto-detect"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, stderr = p.communicate()
    
    if output_callback:
        output_callback(stdout)
        output_callback(stderr)
    
    if status_callback:
        status_callback(stdout.strip(), "blue")
    
    return stdout, stderr


def get_camera_settings(shutter_speed_mapping):
    """
    Get current camera settings (ISO, shutter speed, aperture).
    
    Args:
        shutter_speed_mapping: Dictionary mapping camera values to display values
    
    Returns:
        Dictionary with 'iso', 'shutter', 'aperture' and 'errors' keys
    """
    settings = {"iso": None, "shutter": None, "aperture": None, "errors": []}
    
    try:
        # ISO
        iso_process = subprocess.Popen(
            ["gphoto2", "--get-config", "/main/imgsettings/iso"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        iso_stdout, iso_stderr = iso_process.communicate()
        if iso_stderr:
            settings["errors"].append(f"Error retrieving ISO: {iso_stderr.strip()}")
        else:
            iso_value = iso_stdout.split("Current: ")[1].split("\n")[0].strip()
            settings["iso"] = iso_value

        # Shutter
        shutter_process = subprocess.Popen(
            ["gphoto2", "--get-config", "/main/capturesettings/shutterspeed"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        shutter_stdout, shutter_stderr = shutter_process.communicate()
        if shutter_stderr:
            settings["errors"].append(f"Error retrieving shutter speed: {shutter_stderr.strip()}")
        else:
            shutter_value = shutter_stdout.split("Current: ")[1].split("\n")[0].strip()
            display = shutter_speed_mapping.get(shutter_value, shutter_value)
            settings["shutter"] = {"value": shutter_value, "display": display}

        # Aperture
        aperture_process = subprocess.Popen(
            ["gphoto2", "--get-config", "/main/capturesettings/f-number"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        aperture_stdout, aperture_stderr = aperture_process.communicate()
        if aperture_stderr:
            settings["errors"].append(f"Error retrieving aperture: {aperture_stderr.strip()}")
        else:
            aperture_value = aperture_stdout.split("Current: ")[1].split("\n")[0].strip()
            settings["aperture"] = aperture_value
    except Exception as e:
        settings["errors"].append(f"Error updating camera settings: {str(e)}")
    
    return settings


def set_iso(value, status_callback=None, update_callback=None):
    """
    Set camera ISO setting.
    
    Args:
        value: ISO value to set
        status_callback: Function(status_message, color) to update status
        update_callback: Function to call after setting (to refresh display)
    """
    p = subprocess.Popen(
        ["gphoto2", "--set-config", f"/main/imgsettings/iso={value}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, stderr = p.communicate()
    
    if stderr:
        if status_callback:
            status_callback(f"Error setting ISO: {stderr.strip()}", "red")
    else:
        if status_callback:
            status_callback(f"ISO set to {value}", "green")
    
    if update_callback:
        update_callback()
    
    return stdout, stderr


def set_shutter_speed(value, status_callback=None, update_callback=None):
    """
    Set camera shutter speed.
    
    Args:
        value: Shutter speed value to set
        status_callback: Function(status_message, color) to update status
        update_callback: Function to call after setting (to refresh display)
    """
    p = subprocess.Popen(
        ["gphoto2", "--set-config", f"/main/capturesettings/shutterspeed={value}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, stderr = p.communicate()
    
    if stderr:
        if status_callback:
            status_callback(f"Error setting shutter speed: {stderr.strip()}", "red")
    else:
        if status_callback:
            status_callback(f"Shutter Speed set to {value}", "green")
    
    if update_callback:
        update_callback()
    
    return stdout, stderr


def set_aperture(value, status_callback=None, update_callback=None):
    """
    Set camera aperture.
    
    Args:
        value: Aperture value to set
        status_callback: Function(status_message, color) to update status
        update_callback: Function to call after setting (to refresh display)
    """
    p = subprocess.Popen(
        ["gphoto2", "--set-config", f"/main/capturesettings/f-number={value}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, stderr = p.communicate()
    
    if stderr:
        if status_callback:
            status_callback(f"Error setting aperture: {stderr.strip()}", "red")
    else:
        if status_callback:
            status_callback(f"Aperture set to {value}", "green")
    
    if update_callback:
        update_callback()
    
    return stdout, stderr


def kill_camera_processes():
    """Kill processes that might be blocking the camera."""
    processes_to_kill = ["gphoto2", "PTPCamera"]
    killed = []
    
    for proc_name in processes_to_kill:
        try:
            result = subprocess.run(
                ["killall", proc_name],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=2
            )
            if result.returncode == 0:
                killed.append(proc_name)
        except:
            pass
    
    return killed


def capture_image(save_path, file_extensions, status_callback=None, output_callback=None):
    """
    Capture image and download from camera.
    
    Args:
        save_path: Directory to save captured images
        file_extensions: List of file extensions to look for
        status_callback: Function(status_message, color) to update status
        output_callback: Function(output_text) to display gphoto2 output
    
    Returns:
        List of saved file paths, or empty list on error
    """
    if status_callback:
        status_callback("Processing, please wait...", "blue")
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    if output_callback:
        output_callback("")  # Clear output
    
    # Retry logic for USB claim errors
    max_retries = 3
    retry_delay = 3  # seconds
    
    for attempt in range(max_retries):
        p = subprocess.Popen(
            ["gphoto2", "--capture-image-and-download"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        stdout, stderr = p.communicate()
        
        if output_callback:
            output_callback(stdout)
            output_callback(stderr)
        
        # Check for USB claim error (in English or Portuguese)
        usb_error = (
            stderr and (
                "Could not claim" in stderr or 
                "Não foi possível contactar" in stderr or
                "Error (-53" in stderr or
                "Erro (-53" in stderr or
                "Could not claim the USB device" in stderr
            )
        )
        
        if usb_error:
            if attempt < max_retries - 1:
                # Try to kill blocking processes
                if status_callback:
                    status_callback(
                        f"USB device busy, cleaning up... (attempt {attempt + 1}/{max_retries})",
                        "orange"
                    )
                
                killed = kill_camera_processes()
                
                # Try to reset camera connection
                try:
                    reset_process = subprocess.Popen(
                        ["gphoto2", "--reset"],
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True,
                        timeout=5
                    )
                    reset_process.communicate()
                except:
                    pass  # Reset failed, continue anyway
                
                # Wait before retry
                time.sleep(retry_delay)
                continue
            else:
                if status_callback:
                    status_callback(
                        "Error: Camera USB connection failed. Try: 1) Unplug/replug camera 2) Press camera shutter button 3) Close Image Capture/Photos apps 4) Restart application",
                        "red"
                    )
                return []
        elif stderr:
            if status_callback:
                status_callback(f"Error: {stderr.strip()}", "red")
            return []
        else:
            break  # Success, exit retry loop
    
    files_renamed = []
    try:
        for ext in file_extensions:
            files = glob.glob(f"*{ext}")
            if files:
                latest_file = max(files, key=os.path.getctime)
                new_filename = os.path.join(save_path, f"{timestamp}{ext}")
                os.rename(latest_file, new_filename)
                files_renamed.append(new_filename)
    except Exception as e:
        if status_callback:
            status_callback(f"Error renaming files: {str(e)}", "red")
        return []
    
    if files_renamed:
        if status_callback:
            status_callback(
                f"Image captured and saved: {', '.join(files_renamed)}",
                "green",
            )
    else:
        if status_callback:
            status_callback("No files captured", "red")
    
    return files_renamed


def list_files(output_callback=None, status_callback=None):
    """
    List files on camera.
    
    Args:
        output_callback: Function to call with output text
        status_callback: Function(status_message, color) to update status
    """
    if output_callback:
        output_callback("")  # Clear output
    
    p = subprocess.Popen(
        ["gphoto2", "--list-files"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, stderr = p.communicate()
    
    if output_callback:
        output_callback(stdout)
        output_callback(stderr)
    
    if stderr:
        if status_callback:
            status_callback(f"Error: {stderr.strip()}", "red")
    
    return stdout, stderr


def download_files(output_callback=None, status_callback=None):
    """
    Download all files from camera.
    
    Args:
        output_callback: Function to call with output text
        status_callback: Function(status_message, color) to update status
    """
    if output_callback:
        output_callback("")  # Clear output
    
    p = subprocess.Popen(
        ["gphoto2", "--get-all-files"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, stderr = p.communicate()
    
    if output_callback:
        output_callback(stdout)
        output_callback(stderr)
    
    if stderr:
        if status_callback:
            status_callback(f"Error: {stderr.strip()}", "red")
    else:
        if status_callback:
            status_callback("all files downloaded", "green")
    
    return stdout, stderr

