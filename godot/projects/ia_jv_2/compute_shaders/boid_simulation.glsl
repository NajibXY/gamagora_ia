#[compute]
#version 450

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer Position {
    vec2 data[];
} boid_pos;

layout(set = 0, binding = 1, std430) restrict buffer Velocity {
    vec2 data[];
} boid_vel;

layout(set = 0, binding = 2, std430) restrict buffer Params {
    float number_of_boids;
    float image_size;
    float friendly_radius;
    float avoiding_radius;
    float min_velocity;
    float max_velocity;
    float alignment_factor;
    float cohesion_factor;
    float separation_factor;
    float viewport_x;
    float viewport_y;
    float delta_time;
} params;

layout(rgba16f, binding = 3) uniform image2D boid_data;

void main() {
    int index = int(gl_GlobalInvocationID.x);
    if(index >= params.number_of_boids) return;

    vec2 position = boid_pos.data[index];
    vec2 velocity = boid_vel.data[index];
    vec2 avg_vel = vec2(0.0);
    vec2 middle_pos = vec2(0.0);
    vec2 separation_vec = vec2(0.0);
    int num_friends = 0;
    int num_avoids = 0;

    for (int i=0; i < params.number_of_boids; i++) {
        if (i != index) {
            vec2 other_boid_pos = boid_pos.data[i];
            vec2 other_boid_vel = boid_vel.data[i];
            float dist = distance(position, other_boid_pos);
            if (dist < params.friendly_radius) {
                avg_vel += other_boid_vel;
                middle_pos += other_boid_pos;
                num_friends += 1;
                if (dist < params.avoiding_radius) {
                    separation_vec += position - other_boid_pos;
                    num_avoids += 1;
                }
            }
        }
    }

    if (num_friends > 0) {
        avg_vel /= num_friends;
        velocity += normalize(avg_vel) * params.alignment_factor;

        middle_pos /= num_friends;
        velocity += normalize(middle_pos - position) * params.cohesion_factor;
        if (num_avoids > 0) {
            velocity += normalize(separation_vec) * params.separation_factor;
        }
    }

    // Wall !
    float rotation = 0.0;
    rotation = acos(dot(normalize(velocity), vec2(1.0, 0.0)));
    if (isnan(rotation)) {
        rotation = 0.0;
    } else if (velocity.y < 0) {
        rotation = -rotation;
    }

    float velocity_magnitude = length(velocity);
    velocity_magnitude = clamp(velocity_magnitude, params.min_velocity, params.max_velocity);
    velocity = normalize(velocity) * velocity_magnitude;

    position += velocity * params.delta_time;
    position = vec2(mod(position.x, params.viewport_x), mod(position.y, params.viewport_y));
    
    boid_vel.data[index] = velocity;
    boid_pos.data[index] = position;

    ivec2 pixel_position = ivec2(int(mod(index, params.image_size)), int(index / params.image_size));
    imageStore(boid_data, pixel_position, vec4(position.x, position.y, rotation, 0));

}