## LEFT TODO

+ Resize window
+ Param number of boids
+ Randomize params button
+ Reset params button
- Variations of colorations : heat, etc -- add them as selectable on hud
    + rgb palette
    + test other palettes
        + pastel
    + heat      
    + 2 radio choices with hud options
        + Palettes
            - Imported !!!!
            - Monochromatic with color choice ? Serves as Modulate ?
        + Coloration mode
            + Monochromatic
            + Direction
            + Heat
            + ...
    - Download palettes
    + Download music
    + Parameters on values of scale and values of rescale of the gdshader WITH 0.1 steps up to 10 or 15 !!
    - Mono color choice
    + Rescale on kick
    - Color by friends_group_id ?
    - Parameter stutter_ratio ?
    - ...
    
- Reactions on other sound componenets than bass : other freqs, bpm ?, etc -- add them as selectable on hud
    - https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
    - Mode BPM ? input with a key ?

- Export/import json conf
    + Exported json
    - Pop up
    - Import json
- Export / Import presets and palettes
    - Import all palettes from a specific file on exe
- Input background ?
- Grid optimization
- Midi control with external device (usb ?)
* Add MP3 support
+ Add @export variables to the UI


- ergonomy
    - make parameters and cursor clearer 
    - mp3/wav to ogg conversion with a script using ffmpeg
    - Read OS audio directly ?

#### Rendu

- Use example from photos/videos taken at splntr's
- Make list of ogg examples, with mp3 to ogg converter script access
- Compile and export web ?

#### Variation
- OS Master input as mic input (godot limitation)
- Reaction on voice input -- DB !
- import / change dynamically of color palettes
- stutter fix for colors
- Export video directly for other softs (resolume ?)


### Utils
https://superuser.com/questions/273797/convert-mp3-to-ogg-vorbis
for f in ./*.mp3; do ffmpeg -i "$f" -c:a libvorbis -q:a 8 "${f/%mp3/ogg}"; done

-- Maybe Integrate mp3 to ogg conversion directly
extends Node
func _ready():
    var input_file = "res://path/to/your/audio/file.mp3"
    var output_file = "res://path/to/output/file.ogg"

    convert_mp3_to_ogg(input_file, output_file)

func convert_mp3_to_ogg(input_file: String, output_file: String):
    # Make sure ffmpeg is installed and accessible via shell
    var command = "ffmpeg -i " + input_file + " -c:a libvorbis -q:a 8 " + output_file
    
    # Execute the command and wait for completion
    var result = OS.shell_exec(command)

    if result != "":
        print("Error during conversion: ", result)
    else:
        print("Conversion completed successfully!")