extends Resource

export (String) var texture_source = "STANDARD"
export (String) var path = null


func get_texture(terrain: Node):
	if path == null:
		return null
	var img = Image.new()
	img.load(path)
	return img

func load(obj: Resource):
	self.path = obj.path
