shader_type particles;
//render_mode disable_force, disable_velocity;

uniform sampler2D u_stamp_array;
uniform vec2 u_stamp_size;
uniform vec2 u_chunk_size;
uniform vec2 u_chunk_pos = vec2(0,0);
uniform mat4 u_terrain_inv_transform;
uniform vec3 u_scale = vec3(1.0);
uniform float u_scale_variaton = 0.0;


float get_hash(vec2 c) {
	return fract(sin(dot(c.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 get_array_value(sampler2D array, ivec2 coord)
{
	return texelFetch(array, coord, 0).rg;
}

void vertex() 
{
	if (RESTART) {
		float hash = get_hash(u_chunk_pos.xy);
		vec3 scale = u_scale +  hash*u_scale_variaton*u_scale;

		vec3 pos = vec3(0.0);
		vec2 data_array = get_array_value(u_stamp_array, ivec2(INDEX, 0));
		vec2 data_array_scaled = data_array/(u_stamp_size/u_chunk_size);
		//translating
		pos.x = (data_array_scaled.r);
		pos.z = (data_array_scaled.g);

		TRANSFORM[0][0] *= cos(u_scale_variaton);
		TRANSFORM[0][2] *= -sin(u_scale_variaton);
		TRANSFORM[2][0] *= sin(u_scale_variaton);
		TRANSFORM[2][2] *= cos(u_scale_variaton);
		

		TRANSFORM[3][0] = pos.x;
		TRANSFORM[3][1] = pos.y;
		TRANSFORM[3][2] = pos.z;

		TRANSFORM[0][0] = scale.x;
		TRANSFORM[1][1] = scale.y;
		TRANSFORM[2][2] = scale.z;
	}
}