shader_type particles;

uniform sampler2D stamp_array;
uniform vec2 stamp_size;
uniform vec2 chunk_size;

vec2 get_array_value(sampler2D array, ivec2 coord)
{
	return texelFetch(array, coord, 0).rg/stamp_size*chunk_size;
}

void vertex() 
{
	vec3 pos = vec3(0.0);
	vec2 dataArray = get_array_value(stamp_array, ivec2(INDEX, 0));
	//translating
	pos.x = (dataArray.r);
	pos.z = (dataArray.g);
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z; 
}