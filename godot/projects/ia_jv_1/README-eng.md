# MAKE THEM FEAR

## French Version : [README-eng](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/README.md)

## Author: Najib EL KHADIR
[https://github.com/NajibXY](https://github.com/NajibXY)

## Gamagora 2024/2025 - AI for Video Games

### Context
For this course module, we needed to develop a video game prototype by coding pathfinding algorithms, particularly Dijkstra and A*.

### Prerequisites and Repository Structure
- The code is accessible and reusable in Godot, preferably version 4.3.
- Pathfinding algorithms are available in the folder [IA_JV1/scenes/scripts/utils](https://github.com/NajibXY/gamagora_ia/tree/main/godot/projects/ia_jv_1/scenes/scripts/utils).
- A demo video is available [here](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/MAKE_THEM_FEAR_demo.mp4).
- An executable for directly testing the game: [MAKE_THEM_FEAR.exe](https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/MAKE_THEM_FEAR.exe).

### Game Concept
The idea behind MAKE THEM FEAR is simple: you are a tank facing an army of vehicles you must redirect. These vehicles appear at two different points on the map and seek the shortest path to one of the objectives. Green vehicles need to be directed toward green objectives, and yellow vehicles toward yellow objectives.

You have no ammunition or verbal communication tools. Your only way to redirect vehicles is by threatening them, targeting a point on their current path to force them to recalculate a new route, ideally toward the goal that matches their color.
  
<img src="https://github.com/NajibXY/gamagora_ia/blob/main/godot/projects/ia_jv_1/readme_assets/capture1.png" width="800">

## Key Game Details

### Pathfinding Algorithm Usage
- Green vehicles use Djikstra.
- Yellow vehicles use A*.
- The heuristic used for A* is the Manhattan distance with a weight of 0.5 (modifiable in the code).

### Replayability
- There are 3 difficulty levels, affecting vehicle speed, wait time at their starting position, spawn interval, and movement speed of the player and vehicles on penalizing tiles (grass).
- The goal is to score as many positive points as possible (a vehicle reaching its color-matching goal) and break records across the three game modes.

### Map and Nodes
- I used a TileMap with an isometric 2D view.
- There are two spawn points, two green objectives, and two yellow objectives.
- Black blocks obstruct the player's line of sight.
- Water puddles make parts of the terrain non-navigable for the player and vehicles.
- Grass tiles slow down both the player and vehicles.
- Transition costs: normal tiles = 1, slowing tiles = 3, and walls, water puddles, or player-targeted tiles = +INF.

### Path Calculation, Threading, and Player Influence
- Paths of all instantiated vehicles are shown on the map (it can be cluttered at times, but you get used to it while playing).
- Vehicles move tile by tile, while the player can move continuously across the terrain.
- A vehicle recalculates its shortest path if it’s targeted by the player’s newly defined line of sight on the map when clicked.
- Transitions to newly targeted tiles become +INF, while previously targeted tiles return to their default value.
- Multi-threading was implemented for smoother performance, which could be improved further with semaphores.

## Music by Scott Buckley
- Licence Creative Commons
- Scott Buckley "Freedom"
- Scottt Buckley "Legionnaire"
https://www.youtube.com/@ScottBuckley
