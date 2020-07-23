extends Node

static func _linearize_array(array2d: Array):
	var linear_arr: Array = []
	for data in array2d:
		linear_arr.append(data.x)
		linear_arr.append(data.y)
	return linear_arr

static func _float_to_byte_array(data_in_floats):
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	var data_in_bytes: PoolByteArray = PoolByteArray([])
	for i in data_in_floats:
		stream.clear()
		stream.put_float(i)
		stream.seek(0)
		for _j in range(4):
			data_in_bytes.append(stream.get_8())
	return data_in_bytes

static func generate(array_to_send: Array):
	var img: Image = Image.new()
	var texture: Texture = ImageTexture.new()
	var linear_arr: Array = _linearize_array(array_to_send)
	var byte_arr: PoolByteArray = _float_to_byte_array(linear_arr)
	var tex_width: int = array_to_send.size()
	var tex_heigh: int = 1
	img.create_from_data(tex_width, tex_heigh, false, Image.FORMAT_RGF, byte_arr)
	texture.create_from_image(img, 0)
	return texture
