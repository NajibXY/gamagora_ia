# BOIIIIIIIIIII: An Audio-Reactive, Boids-Based VJing Tool

## [Project Repository](https://github.com/NajibXY/gamagora_ia/tree/main/godot/projects/ia_jv_2)

## English Version [README-eng](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_2/README-eng.md)

## Author: Najib EL KHADIR  
https://github.com/NajibXY  

## Gamagora 2024/2025 - AI for Video Games

### Context
As part of this course, the goal was to develop a prototype video game or interactive application using the Boids algorithm concept.

### Prerequisites and Repository Structure
- The code is openable and reusable in Godot, preferably version 4.3.
- The Boids update algorithm, based on the three principles of alignment, separation, and cohesion, is implemented here: [IA_JV1/scenes/scripts/utils](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_2/compute_shaders/boid_simulation.glsl).

- A demo video is available here: [BOIIIIIIIIIII](https://youtu.be/sZoQeEu2l5o).  
- An executable for testing the application is also available: [BOIIIIIIIIIII.exe]().

### Concept of the Application
The idea behind **BOIIIIIIIIIII** is to provide, in its current form, an interactive tool for visualizing boids, customizing their parameters, and—most importantly—making them audio-reactive.  

For novice users, it can be used as an MP3 player with fascinating visuals to observe. The parameterization possibilities for the boids are nearly limitless, and the audio reactivity adds a unique artistic dimension.  

For advanced users, a future, more polished version of this project could serve as a full-fledged VJing tool (VJ = Visual Jockey, analogous to a DJ).

</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/18f9a318d247102a46fcb58e1397f505c858cff0/godot/projects/ia_jv_2/readme_assets/default.gif" width="800">
</br>

---

## Key Details of the Application

### Test Files
The provided application ZIP [BOIIIIIIIIIII.exe]() includes several `.ogg` audio files and `.png` color palettes for testing.

### Controls and Interactivity
The application allows the following actions during runtime:  
- **F**: Select an `.ogg` audio file to play.  
- **G**: Choose a `.png` color palette to add. These palettes are imported into Godot's `user://` directory, which corresponds to `AppData\Roaming\Godot\app_userdata\BOIIIIIIIIIII` on Windows.  
- Users can interact with various parameters in the Canvas Layer to experiment with audio reactivity, basic boid behavior, or both simultaneously.  
- **J**: Export the current configuration as a `.json` file, which is also stored in the `user://` directory.  
- **K**: Import a previously saved configuration.  
- **R**: Reset all parameters.  
- **SPACE**: The "magic" or "doom-scrolling" key, randomizes all parameters. This feature can be a source of endless fun as users loop through configurations to find one they like. (*LONG LIVE RANDOMIZATION!*)  

### Boid Parameters
The boids have eight standard parameters, commonly used in this type of implementation:

</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/18f9a318d247102a46fcb58e1397f505c858cff0/godot/projects/ia_jv_2/readme_assets/params1.png" width="800">
</br>

---

### Bass Audio-Reactivity Parameters

#### Multipliers and Dividers
An additional set of eight parameters acts as multipliers or dividers, affecting how boids react to bass frequencies in the played music:  

</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/18f9a318d247102a46fcb58e1397f505c858cff0/godot/projects/ia_jv_2/readme_assets/params2.png" width="800">
</br>

- The `stutter_on_kick` parameter causes boids to spin around randomly and then return to normal behavior. When triggered by bass frequencies, this can create stunning visual effects.

---

### Coloring Parameters
Three coloring modes are currently implemented:  
1. **Monochromatic Coloring**  
2. **Direction-Based Coloring**  
3. **Temperature-Based Coloring** (mainly influenced by the "Friendly Radius" parameter).  

</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/18f9a318d247102a46fcb58e1397f505c858cff0/godot/projects/ia_jv_2/readme_assets/params3.png" width="800">
</br>

---

### Boid Scaling and Material Rescaling Parameters
- The boid triangles can be resized, allowing users to experiment with fine particle effects, angel-hair-like visuals, or oversized, chunky triangles.  
- A rescaling parameter enables boid size changes during audio reactivity. This is one of the most critical parameters as it can produce beautiful results or overly stroboscopic/epileptic effects—so use it cautiously!  
- These parameters can be locked (preventing randomization) via the "able scaling rand" option.  

</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/18f9a318d247102a46fcb58e1397f505c858cff0/godot/projects/ia_jv_2/readme_assets/params4.png" width="800">
</br>

---

### Bass Reactivity Threshold Parameters (Experimental)
The most recently added parameters allow setting the magnitude threshold and frequency range for bass audio reactivity.  

These parameters help prevent excessive boid movement when playing bass-heavy music (e.g., Drum & Bass), ensuring more controlled audio reactivity.

</br>
  <img src="https://github.com/NajibXY/gamagora_ia/blob/18f9a318d247102a46fcb58e1397f505c858cff0/godot/projects/ia_jv_2/readme_assets/params5.png" width="800">
</br>  

--- 
