shader_type particles;
render_mode disable_force, disable_velocity;

uniform sampler2D u_densitymap;
uniform sampler2D u_stamp_array;
uniform vec2 u_stamp_size;
uniform vec2 u_chunk_size;
uniform vec2 u_chunk_pos = vec2(0,0);
uniform float u_dithering_scale = 10.0;
uniform mat4 u_terrain_inv_transform;
uniform vec3 u_scale = vec3(1.0);
uniform float u_scale_variaton = 0.0;
uniform vec2 u_terrain_size = vec2(1,1);
uniform vec2 u_terrain_pivot = vec2(0.5,0.5);


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

bool dither_object(float fade, vec2 pos)
{

	int x = int(pos.x) % 4;
	int y = int(pos.y) % 4;
	int index = x + y * 4;
	float limit = 0.0;

	if (index == 0) limit = 0.0625;
	if (index == 1) limit = 0.5625;
	if (index == 2) limit = 0.1875;
	if (index == 3) limit = 0.6875;
	if (index == 4) limit = 0.8125;
	if (index == 5) limit = 0.3125;
	if (index == 6) limit = 0.9375;
	if (index == 7) limit = 0.4375;
	if (index == 8) limit = 0.25;
	if (index == 9) limit = 0.75;
	if (index == 10) limit = 0.125;
	if (index == 11) limit = 0.625;
	if (index == 12) limit = 1.0;
	if (index == 13) limit = 0.5;
	if (index == 14) limit = 0.875;
	if (index == 15) limit = 0.375;

	return (fade < limit);
}


void vertex() 
{
	if (RESTART) {
		float hash = get_hash(u_chunk_pos.xy);
		vec3 scale = u_scale +  hash*u_scale_variaton*u_scale;

		vec3 pos = vec3(0.0);
		vec2 data_array = get_array_value(u_stamp_array, ivec2(INDEX, 0));
		data_array = flip_array(data_array, hash);
		vec2 data_array_scaled = data_array/(u_stamp_size/u_chunk_size);
		//translating
		pos.x = (data_array_scaled.r);
		pos.z = (data_array_scaled.g);

		vec4 obj_pos = vec4(u_chunk_pos.x + pos.x, 0, u_chunk_pos.y + pos.z, 1);

		vec3 cell_coords = (u_terrain_inv_transform * obj_pos).xyz;
		cell_coords.xz += u_terrain_pivot;
		//tranform to 0..1
		vec2 terrain_uv =  cell_coords.xz/u_terrain_size;
		float density = texture(u_densitymap, terrain_uv).r;
		if (dither_object(density,data_array / u_dithering_scale))
		{
			//it doesn't seem that it removes an instance of object
			pos.y = -100000000.0;
			TRANSFORM[0][0] = 0.0;
			ACTIVE = false;
		}

		TRANSFORM[0][0] *= cos(u_scale_variaton);
		TRANSFORM[0][2] *= -sin(u_scale_variaton);
		TRANSFORM[2][0] *= sin(u_scale_variaton);
		TRANSFORM[2][2] *= cos(u_scale_variaton);

		TRANSFORM[3][0] = pos.x;
		TRANSFORM[3][1] = pos.y;
		TRANSFORM[3][2] = pos.z;

		TRANSFORM[0][0] *= scale.x;
		TRANSFORM[1][1] *= scale.y;
		TRANSFORM[2][2] *= scale.z;
	}
}