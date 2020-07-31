extends Spatial

export (Resource) var biome_resource = null
export (Vector2) var chunk_size = Vector2(10, 10)
export (Vector2) var chunk_position = Vector2(0, 0)
export (Transform) var terrain_inv_transform
export (Vector2) var terrain_size = Vector2(1, 1)
export (Vector2) var terrain_pivot = Vector2(0.5, 0.5)

enum MESH_RENDER { Multimesh, Particles, Particles_GPU_density }
export (MESH_RENDER) var mesh_renderer = MESH_RENDER.Multimesh

var terrain: Node = null

var _biomes_subsets = []
const BiomeSubsetParticlesRenderer = preload("res://addons/biomes/scripts/runtime/BiomeSubsetParticlesRenderer.gd")
const BiomeSubsetMultimeshRenderer = preload("res://addons/biomes/scripts/runtime/BiomeSubsetMultimeshRenderer.gd")


func create_subset_renderer(biome_placement_node, sampling_provider, dithering_scale):
	var subset = null
	match mesh_renderer:
		MESH_RENDER.Particles:
			subset = BiomeSubsetParticlesRenderer.new()
		MESH_RENDER.Particles_GPU_density:
			subset = BiomeSubsetParticlesRenderer.new()
			subset.gpu_compute = true
		_:
			subset = BiomeSubsetMultimeshRenderer.new()

	subset.id = biome_placement_node.id
	subset.mesh = biome_placement_node.mesh
	subset.chunk_size = chunk_size
	subset.chunk_position = chunk_position
	subset.stamp_size = sampling_provider.stamp_size
	subset.enable_shadows = biome_placement_node.cast_shadow
	subset.densitymap = biome_resource.get_densitymap(terrain)
	subset.heightmap = biome_resource.get_heightmap(terrain)
	subset.terrain_inv_transform = terrain_inv_transform
	subset.dithering_scale = dithering_scale
	subset.object_scale = biome_placement_node.scale
	subset.object_scale_variation = biome_placement_node.scale_variation
	subset.terrain_size = terrain_size
	subset.terrain_pivot = terrain_pivot

	self.add_child(subset)

	return subset


func generate(sampling_provider: Node):
	var biome: Object = null
	biome_resource.clear_cache()
	var biome_data: Array = biome_resource.get_biome_subsets()
	var dithering_scale = biome_resource.get_min_footprint()
	for x in biome_data:
		biome = create_subset_renderer(x, sampling_provider, dithering_scale)
		biome.sampling_array = sampling_provider.query_points_by_id(x.id)
		biome.generate()
		_biomes_subsets.append(biome)

func update_chunk():
	for x in _biomes_subsets:
		x.generate()