extends Resource

export (String) var texture_source = "ZYLANN"
enum TEXTURE_TYPE { HEIGHT, NORMAL, DETAIL, ALBEDO, COLOR, SPLAT }
export (TEXTURE_TYPE) var type = TEXTURE_TYPE.HEIGHT
export (int) var layer = 0


func _zylannn_img(td, channel, layer = 0):
	if Engine.is_editor_hint():
		return td.get_image(channel, layer)
	else:
		return td.get_texture(channel, layer).get_data()


func get_texture(terrain: Node):
	var HTerrainData = terrain.HTerrainData
	var td = terrain.get_data()
	match self.type:
		TEXTURE_TYPE.HEIGHT:
			return _zylannn_img(td, HTerrainData.CHANNEL_HEIGHT)
		TEXTURE_TYPE.NORMAL:
			return _zylannn_img(td, HTerrainData.CHANNEL_NORMAL)
		TEXTURE_TYPE.ALBEDO:
			return _zylannn_img(td, HTerrainData.CHANNEL_GLOBAL_ALBEDO)
		TEXTURE_TYPE.DETAIL:
			return _zylannn_img(td, HTerrainData.CHANNEL_DETAIL, self.layer)
		TEXTURE_TYPE.COLOR:
			return _zylannn_img(td, HTerrainData.CHANNEL_COLOR, self.layer)
		TEXTURE_TYPE.SPLAT:
			return _zylannn_img(td, HTerrainData.CHANNEL_SPLAT, self.layer)


func load(obj: Resource):
	self.type = obj.type
	self.layer = obj.layer
