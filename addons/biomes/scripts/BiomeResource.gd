extends Resource

export(Array) var biome_subsets = []
export(String) var biome_density_map_path = null

var _biome_density_map: Image = null
var _biome_min_footprint: float = -1.0


func get_densitymap():
	if _biome_density_map == null:
		_biome_density_map = Image.new()
		_biome_density_map.load(biome_density_map_path)
	return _biome_density_map


func get_biome_subsets():
	return biome_subsets

func get_min_footprint():
	if _biome_min_footprint == -1.0:
		_biome_min_footprint= biome_subsets[0].footprint
		for x in biome_subsets:
			_biome_min_footprint = min(_biome_min_footprint, x.footprint)
	return _biome_min_footprint
