## Base
+ Change valuations for targetted cells and links
- Refactor initialization of valuations
+ global_path_nodes in game_scene
+ id and + path_cells for car_scene
+ Add id to global_cells and refactor, for conflicts between cars ?
+ pop a cell when its used
+ if a cell is in global_paths it comes back to path nature after aiming..

+ ! Instantiate !
+ ! A star !
+ Sheep game ? Multiple colors for multiple goals ?

+ change path tiles color etc
+ add sprites for cars and directions / switch from moveto to translate
+ upgrade map

* add two invisible block line that blocks targetting and movement for player for goals and spawns
* regroup consts in a util.consts file
* add multiple heuristics ?
* "Objection" when locking target
* Maybe switch djikstra users to taking first goal, since there should be an efficiency difference between it and a star
    -- Well there is one, since A star sometimes chooses fastly the a heuristically correct path


## Optimizations
+ Check why djikstra blocks game -- Threading done, maybe use Semaphor for further more improvement ?
    - Number of points approximating tiles between tank and target should depend on the distance
- Path2D node to represent a path in 2D space.
- Shader for color things, find a way to debug positions.

## TODO rendu

+ Score
+ Controls
+ Highest Score stored in three files per difficulty
+ Press R to reload
+ Menu with difficulties 
+ escape to pause/go to menu
- Background 
- Music
- Intro ?
- Readme de rendu avec explications des scripts etc ET VIDEO !!


