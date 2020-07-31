extends Resource

export (String) var texture_source = "ZYLANN"
enum TEXTURE_TYPE { HEIGHT, NORMAL, DETAIL, ALBEDO }
export (TEXTURE_TYPE) var type = TEXTURE_TYPE.HEIGHT
export (int) var layer = 0


func get_texture(terrain: Node):
	var HTerrainData = terrain.HTerrainData
	print(terrain)
	var td = terrain.get_data()
	match self.type:
		TEXTURE_TYPE.HEIGHT:
			return td.get_image(HTerrainData.CHANNEL_HEIGHT)
		TEXTURE_TYPE.NORMAL:
			return td.get_image(HTerrainData.CHANNEL_NORMAL)
		TEXTURE_TYPE.ALBEDO:
			return td.get_image(HTerrainData.CHANNEL_GLOBAL_ALBEDO)
		TEXTURE_TYPE.DETAIL:
			return td.get_image(HTerrainData.CHANNEL_DETAIL, self.layer)

func load(obj: Resource):
	self.type = obj.type
	self.layer = obj.layer
