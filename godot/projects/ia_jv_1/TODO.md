## Base
+ Change valuations for targetted cells and links
- Refactor initialization of valuations
+ global_path_nodes in game_scene
- id and + path_cells for car_scene
- Add id to global_cells and refactor, for conflicts between cars ?
- pop a cell when its used
- if a cell is in global_paths it comes back to path nature after aiming..

- add two invisible block line that blocks targetting and movement for player for goals and spawns
- change map
- if you change 4 times the path of an ennemy it dies ?
- "Objection" when locking target



## Optimizations
- Check why djikstra blocks game
    - Number of points approximating tiles between tank and target should depend on the distance
- Path2D node to represent a path in 2D space.
- Shader for color shit, find a way to debug positions.

