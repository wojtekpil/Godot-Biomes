extends Resource

export (String) var texture_source = "STANDARD"
export (String) var path = null


func get_texture(terrain: Node):
	if path == null:
		return null
	if Engine.is_editor_hint():
		var img = Image.new()
		img.load(path)
		return img
	else:
		return load(path).get_data()

func load(obj: Resource):
	self.path = obj.path
