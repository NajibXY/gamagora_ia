shader_type particles;

//todo
uniform uint color_mode;

uniform sampler2D t_sampler;

uniform uint max_friends;

uniform sampler2D boid_data;
uniform bool is_kick;

uniform vec4 current_color : source_color;

// TODO fine tune
uniform vec2 rescale = vec2(1.0, 1.0);
uniform vec2 scale = vec2(.5, .5);

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	ivec2 pos_image_size = textureSize(boid_data, 0);

	ivec2 texel_pos = ivec2(int(mod(float(INDEX),float(pos_image_size.x))),
							int(float(INDEX)/float(pos_image_size.x)));

	vec4 boid_pos_rot = texelFetch(boid_data, texel_pos, 0);

	mat2 scale_rot_mat = mat2(vec2(cos(boid_pos_rot.b), sin(boid_pos_rot.b)), // First column
							  vec2(-sin(boid_pos_rot.b), cos(boid_pos_rot.b))); // Second column



	if (is_kick) {
		// float rnd_enter = fract(sin(dot(boid_pos_rot.rg, vec2(27.2626, 88.932))) * 54676.4224);
		// if (rnd_enter > 0.5) {
		// minimum clamp to avoid too small scale
		vec2 rescale_new = vec2(max(rescale.x, 0.1), max(rescale.y, 0.1));
		scale_rot_mat[0] *= max(rescale_new * scale.x, 0.1);
		scale_rot_mat[1] *= max(rescale_new * scale.y, 0.1);
		// }
	}
	else {
		scale_rot_mat[0] *= scale.x;
		scale_rot_mat[1]*= scale.y;
	}

	TRANSFORM[0].xy = scale_rot_mat[0];
	TRANSFORM[1].xy = scale_rot_mat[1];
	TRANSFORM[3].xy = vec2(boid_pos_rot.r, boid_pos_rot.g);

	// TODO: adapt the color to the color mode
	//COLOR = texture(heading_sampler, vec2(0, degrees(boid_pos_rot.b / 360.0)));
	// Color on number of friends
	COLOR = texture(t_sampler, clamp(vec2(0, boid_pos_rot.a / float(max_friends)), .01, .99));

	switch (color_mode) {
		case 0: // Mono current color
			COLOR = current_color;
			break;
		case 1: // Heading
			COLOR = texture(t_sampler, vec2(0, degrees(boid_pos_rot.b / 360.0)));
			break;
		case 2: // Heat
			COLOR = texture(t_sampler, clamp(vec2(0, boid_pos_rot.a / float(max_friends)), .01, .99));
			break;
	}

}
