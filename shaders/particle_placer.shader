shader_type particles;

uniform sampler2D stamp_array;
uniform vec2 stamp_size;
uniform vec2 chunk_size;
uniform vec2 chunk_pos = vec2(0,0);


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
		return vec2(da.x, stamp_size.y - da.y);
	}
	if(hash > 0.50)
	{
		return vec2(stamp_size.x - da.x, da.y);
	}
	if(hash > 0.75)
	{
		return vec2(stamp_size.x - da.x, stamp_size.y - da.y);
	}
	return da;
}

void vertex() 
{
	float hash = get_hash(chunk_pos.xy);

	vec3 pos = vec3(0.0);
	vec2 data_array = get_array_value(stamp_array, ivec2(INDEX, 0));
	data_array = flip_array(data_array, hash);
	data_array /= stamp_size/chunk_size;
	//translating
	pos.x = (data_array.r);
	pos.z = (data_array.g);
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z; 
}