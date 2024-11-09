import os
import subprocess

# Get all .mp3 files in the current directory
files = [f for f in os.listdir('.') if f.endswith('.mp3')]

# Convert each .mp3 to .ogg using ffmpeg
for f in files:
    # Define the output filename by replacing .mp3 with .ogg
    output_filename = f.replace('.mp3', '.ogg')
    
    # Build the ffmpeg command as a list of arguments
    command = [
        'ffmpeg',           # Command to run ffmpeg
        '-i', f,            # Input file (the .mp3 file)
        '-c:a', 'libvorbis', # Audio codec (libvorbis for .ogg)
        '-q:a', '8',         # Audio quality (value 8 is typical for a good balance)
        output_filename     # Output file (the .ogg file)
    ]
    
    # Execute the command
    result = subprocess.run(command, capture_output=True, text=True)

    # Check for any errors during conversion
    if result.returncode != 0:
        print(f"Error converting {f}: {result.stderr}")
    else:
        print(f"Successfully converted {f} to {output_filename}")