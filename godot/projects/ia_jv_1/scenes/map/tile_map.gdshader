shader_type canvas_item;

uniform vec2 selected_tile = vec2(0.0, 0.0); // The tile coordinate you want to colorize (in tile units)
//uniform vec4 selected_color:hint_color = vec4(1.0, 0.0, 0.0, 1.0); // Color to apply to the selected tile
uniform vec2 tile_size = vec2(29.0, 15.0); // Tile size in pixels for isometric (adjust based on your isometric tile dimensions)

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    //vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    //vec2 coord = UV * tex_size;
//
    //// Calculate the coordinates in tile units
    //float x = coord.x / tile_size.x;
    //float y = coord.y / tile_size.y;
//
    //// Calculate the isometric tile coordinates
    //vec2 tile_coord;
    //tile_coord.x = floor(x); // Isometric X
    //tile_coord.y = floor(y); // Isometric Y with vertical offset
//
    //// Visualize tile coordinates for debugging (uncomment if needed)
    //if (int(tile_coord.x) % 2 == 0) {
		////COLOR = vec4(1.0,0.0,0.0,1.0);
	//}

    // vec4 tex_color = texture(TEXTURE, UV);

    // // Colorize only the selected tile
    // if (tile_coord == selected_tile) {
    //     tex_color.rgb = mix(tex_color.rgb, selected_color.rgb, selected_color.a);
    // }

    // COLOR = tex_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
