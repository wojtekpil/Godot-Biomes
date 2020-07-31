extends Resource

export(Array) var biome_subsets = []
export(String) var biome_density_map_path = null
export(Resource) var biome_heightmap = null

var _biome_density_map: Image = null
var _biome_height_map: Image = null
var _biome_min_footprint: float = -1.0

const BiomeZylannTexture = preload("res://addons/biomes/scripts/BiomeZylannTextureResurce.gd")

func get_densitymap():
	if _biome_density_map == null:
		_biome_density_map = Image.new()
		_biome_density_map.load(biome_density_map_path)
	return _biome_density_map


func get_heightmap(terrain: Node):
	if _biome_height_map != null:
		return _biome_height_map
	if biome_heightmap == null:
		return null
	if biome_heightmap.texture_source == "ZYLANN":
		var bz = BiomeZylannTexture.new()
		bz.load(biome_heightmap)
		_biome_height_map = bz.get_texture(terrain)
		print("Loaded Zylann heightmap")
	return _biome_height_map


func get_biome_subsets():
	return biome_subsets

func get_min_footprint():
	if _biome_min_footprint == -1.0:
		_biome_min_footprint= biome_subsets[0].footprint
		for x in biome_subsets:
			_biome_min_footprint = min(_biome_min_footprint, x.footprint)
	return _biome_min_footprint

func load(data: Resource):
	self.biome_subsets = data.biome_subsets
	self.biome_density_map_path = data.biome_density_map_path
	self.biome_heightmap = data.biome_heightmap

func clear_cache():
	_biome_density_map = null
	_biome_height_map = null
	#_biome_min_footprint = -1.0