shader_type particles;
render_mode disable_force, disable_velocity;

uniform sampler2D u_densitymap;
uniform sampler2D u_stamp_array;
uniform vec2 u_stamp_size;
uniform vec2 u_chunk_size;
uniform vec2 u_chunk_pos = vec2(0,0);
uniform mat4 u_terrain_inv_transform;


float get_hash(vec2 c) {
	return fract(sin(dot(c.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 get_array_value(sampler2D array, ivec2 coord)
{
	return texelFetch(array, coord, 0).rg;
}

vec2 flip_array(vec2 da, float hash)
{
	if(hash > 0.25)
	{
		return vec2(da.x, u_stamp_size.y - da.y);
	}
	if(hash > 0.50)
	{
		return vec2(u_stamp_size.x - da.x, da.y);
	}
	if(hash > 0.75)
	{
		return vec2(u_stamp_size.x - da.x, u_stamp_size.y - da.y);
	}
	return da;
}

void vertex() 
{
	if (RESTART) {
		float hash = get_hash(u_chunk_pos.xy);

		vec3 pos = vec3(0.0);
		vec2 data_array = get_array_value(u_stamp_array, ivec2(INDEX, 0));
		data_array = flip_array(data_array, hash);
		vec2 data_array_scaled = data_array/(u_stamp_size/u_chunk_size);
		//translating
		pos.x = (data_array_scaled.r);
		pos.z = (data_array_scaled.g);
		mat4 mat = mat4(1);

		vec4 obj_pos = vec4(u_chunk_pos.x + pos.x, 0, u_chunk_pos.y + pos.z, 1);

		vec3 cell_coords = (u_terrain_inv_transform * obj_pos).xyz;
		//TODO: temporary
		//terrain transform if from the center of 32x32 plane
		cell_coords.xz += 16f;
		//TODO: it should be passed via uniform (terrain size?), tranform to 0..1
		vec2 terrain_uv =  cell_coords.xz/32f;
		float density = texture(u_densitymap, terrain_uv).r;
		if (density < 0.5)
		{
			//it doesn't seem that it removes an instance of object
			pos.y = -100000000.0;
			TRANSFORM[0][0] = 0.0;
			ACTIVE = false;
		}
		TRANSFORM[3][0] = pos.x;
		TRANSFORM[3][1] = pos.y;
		TRANSFORM[3][2] = pos.z;
	}
}