extends Spatial

export (Resource) var biome_resource = null
export (Vector2) var chunk_size = Vector2(10, 10)
export (Vector2) var chunk_position = Vector2(0, 0)
export (Transform) var terrain_inv_transform

enum MESH_RENDER { Multimesh, Particles, Particles_GPU_density }
export (MESH_RENDER) var mesh_renderer = MESH_RENDER.Multimesh

var _biomes_subsets = []

var BiomeSubsetParticlesRenderer = preload("res://addons/biomes/scripts/runtime/BiomeSubsetParticlesRenderer.gd")
var BiomeSubsetMultimeshRenderer = preload("res://addons/biomes/scripts/runtime/BiomeSubsetMultimeshRenderer.gd")


func create_subset_renderer(biome_placement_node, sampling_provider, dithering_scale):
	var particles = null
	match mesh_renderer:
		MESH_RENDER.Particles:
			particles = BiomeSubsetParticlesRenderer.new()
		MESH_RENDER.Particles_GPU_density:
			particles = BiomeSubsetParticlesRenderer.new()
			particles.gpu_compute = true
		_:
			particles = BiomeSubsetMultimeshRenderer.new()

	particles.id = biome_placement_node.id
	particles.mesh = biome_placement_node.mesh
	particles.chunk_size = chunk_size
	particles.chunk_position = chunk_position
	particles.stamp_size = sampling_provider.stamp_size
	particles.enable_shadows = biome_placement_node.cast_shadow
	particles.densitymap = biome_resource.get_densitymap()
	particles.terrain_inv_transform = terrain_inv_transform
	particles.dithering_scale = dithering_scale
	particles.object_scale = biome_placement_node.scale
	particles.object_scale_variation = biome_placement_node.scale_variation

	self.add_child(particles)

	return particles


func generate(sampling_provider: Node):
	var biome: Object = null
	var biome_data: Array = biome_resource.get_biome_subsets()
	var dithering_scale = biome_resource.get_min_footprint()
	for x in biome_data:
		biome = create_subset_renderer(x, sampling_provider, dithering_scale)
		biome.sampling_array = sampling_provider.query_points_by_id(x.id)
		biome.generate()
		_biomes_subsets.append(biome)
