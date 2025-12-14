# Camera Control Configuration
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
# Pro/Astro: .tif, .tiff, .fits, .fit
file_extensions = [".jpg", ".nef", ".cr2", ".arw", ".raf", ".orf", ".rw2", ".dng", ".3fr", ".pef", ".tif", ".tiff", ".fits", ".fit"]

# Add more configuration options here in the future
# Example:
# default_iso = 400
# default_aperture = "f/5.6"
