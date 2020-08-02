extends Resource

export (Array) var biome_subsets = []
export (Resource) var biome_density = null
export (Resource) var biome_heightmap = null

var _biome_density_map: Image = null
var _biome_height_map: Image = null
var _biome_min_footprint: float = -1.0

const BiomeTexture = preload("res://addons/wojtekpil.biomes/scripts/BiomeTextureResource.gd")
const BiomeZylannTexture = preload("res://addons/wojtekpil.biomes/scripts/BiomeZylannTextureResource.gd")


func _get_image(image: Resource, terrain: Node):
	if image == null:
		return null
	if image.texture_source == "ZYLANN":
		var bz = BiomeZylannTexture.new()
		bz.load(image)
		return bz.get_texture(terrain)
	if image.texture_source == "STANDARD":
		var ts = BiomeTexture.new()
		ts.load(image)
		return ts.get_texture(terrain)
	return null


func get_densitymap(terrain: Node):
	if _biome_density_map != null:
		return _biome_density_map
	_biome_density_map = _get_image(biome_density, terrain)
	return _biome_density_map


func get_heightmap(terrain: Node):
	if _biome_height_map != null:
		return _biome_height_map
	_biome_height_map = _get_image(biome_heightmap, terrain)
	return _biome_height_map


func get_biome_subsets():
	return biome_subsets


func get_min_footprint():
	if _biome_min_footprint == -1.0:
		_biome_min_footprint = biome_subsets[0].footprint
		for x in biome_subsets:
			_biome_min_footprint = min(_biome_min_footprint, x.footprint)
	return _biome_min_footprint


func load(data: Resource):
	self.biome_subsets = data.biome_subsets
	self.biome_density = data.biome_density
	self.biome_heightmap = data.biome_heightmap


func clear_cache():
	_biome_density_map = null
	_biome_height_map = null
	#_biome_min_footprint = -1.0
