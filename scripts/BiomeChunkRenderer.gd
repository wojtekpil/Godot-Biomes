extends Spatial

export (Array) var biome_data = []
export (Vector2) var chunk_size = Vector2(10, 10)
export (Vector2) var chunk_position = Vector2(0, 0)

var _biomes_subsets = []

var BiomeSubsetRenderer = preload("res://scripts/BiomeSubsetRenderer.gd")


func create_subset_renderer(biome_placement_node, sampling_provider):
	var particles = BiomeSubsetRenderer.new()
	particles.id = biome_placement_node.id
	particles.mesh = biome_placement_node.mesh
	particles.chunk_size = chunk_size
	particles.chunk_position = chunk_position
	particles.stamp_size = sampling_provider.stamp_size
	particles.enable_shadows = biome_placement_node.cast_shadow

	self.add_child(particles)

	return particles


func generate(sampling_provider: Node):
	var biome: Object = null
	for x in biome_data:
		biome = create_subset_renderer(x, sampling_provider)
		biome.sampling_array = sampling_provider.query_points_by_id(x.id)
		biome.generate()
		_biomes_subsets.append(biome)

