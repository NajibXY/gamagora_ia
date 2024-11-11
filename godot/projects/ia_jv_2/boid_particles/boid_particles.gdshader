shader_type particles;


uniform sampler2D boid_data;
uniform sampler2D heading_sampler;

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
	
	scale_rot_mat[0] *= scale.x;
	scale_rot_mat[1] *= scale.y;
	scale_rot_mat[0] *= rescale;
	scale_rot_mat[1] *= rescale;
	
	TRANSFORM[0].xy = scale_rot_mat[0];
	TRANSFORM[1].xy = scale_rot_mat[1];
	TRANSFORM[3].xy = vec2(boid_pos_rot.r, boid_pos_rot.g); 

	// TODO: adapt the color to the color mode
	COLOR = texture(heading_sampler, vec2(0, degrees(boid_pos_rot.b / 360.0)));

}
