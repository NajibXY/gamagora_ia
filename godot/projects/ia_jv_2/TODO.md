## LEFT TODO
- Randimize params button
- Reset params button
- Variations of colorations : heat, etc 
- Reactions on other sound componenets than bass : other freqs, bpm ?, etc
- Grid optimization
* Add MP3 support
+ Add @export variables to the UI

- ergonomy
    - cursor color
    - mp3/wav to ogg conversion with a scrript using ffmpeg

- Make list of ogg examples, with mp3 to ogg converter script access
- Compile and export web

#### Variation
- Reaction on voice input -- DB !


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