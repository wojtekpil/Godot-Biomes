tool
extends Spatial

export (Resource) var biome = null
export (Vector2) var chunk_size = Vector2(32, 32)
export (float) var visibility_range = 10
export (NodePath) var terrain = null

enum MESH_RENDER { Multimesh, Particles, Particles_GPU_density }
export (MESH_RENDER) var mesh_renderer = MESH_RENDER.Multimesh

var _biomes: Array = []
var _sampling_provider_script = preload("res://addons/biomes/scripts/PoissonDisc.gd")

var BiomeChunkRenderer = preload("res://addons/biomes/scripts/runtime/BiomeChunkRenderer.gd")
var BiomeDummyResource = preload("res://scripts/BiomeDummyResource.gd")
var BiomeResource = preload("res://addons/biomes/scripts/BiomeResource.gd")

onready var _biome_resource = BiomeResource.new()
onready var _sampling_provider = _sampling_provider_script.new()
onready var _terrain = get_node(terrain)


func _bootstrap_biome():
	_biome_resource.load(biome)
	var biome_placement_nodes = _biome_resource.get_biome_subsets()
	_sampling_provider.setup_biome_placement_nodes(biome_placement_nodes)


func _create_chunk_renderer(
	chunk_position: Vector2,
	terrain_inv_transform: Transform,
	terrain_size: Vector2,
	terrain_pivot: Vector2
):
	var chunk = BiomeChunkRenderer.new()
	chunk.chunk_size = chunk_size
	chunk.chunk_position = chunk_position
	chunk.biome_resource = _biome_resource
	chunk.terrain_inv_transform = terrain_inv_transform
	chunk.mesh_renderer = mesh_renderer
	chunk.terrain_size = terrain_size
	chunk.terrain_pivot = terrain_pivot
	chunk.terrain = _terrain

	self.add_child(chunk)
	return chunk


func _get_terrain_inv_transform(terrain: Node):
	if terrain is MeshInstance:
		return _terrain.transform.affine_inverse()
	if "HTerrainData" in terrain:  #its Zylann's
		var gt = terrain.get_internal_transform()
		return gt.affine_inverse()


func _get_terrain_size(terrain: Node):
	if terrain is MeshInstance:
		return _terrain.mesh.size
	if "HTerrainData" in terrain:  #its Zylann's
		var map_res = terrain.get_data().get_resolution()
		var map_scale = terrain.map_scale
		return Vector2(map_scale.x * map_res, map_scale.z * map_res)


func _get_terrain_pivot(terrain: Node):
	if terrain is MeshInstance:
		return _terrain.mesh.size / 2.0
	if "HTerrainData" in terrain:  #its Zylann's
		return Vector2(0, 0)


func _setup_live_update(terrain: Node):
	if "HTerrainData" in terrain:  #its Zylann's
		terrain.get_data().connect("region_changed", self, "_on_data_region_changed")


# Called when the node enters the scene tree for the first time.
func _ready():
	if biome == null || _terrain == null:
		print("No biome or terrain selected")
		return
	var terrain_inv_transform: Transform = _get_terrain_inv_transform(_terrain)
	var terrain_size: Vector2 = _get_terrain_size(_terrain)
	var terrain_pivot: Vector2 = _get_terrain_pivot(_terrain)
	_bootstrap_biome()
	_setup_live_update(_terrain)
	_sampling_provider.connect("stamp_updated", self, "_on_stamp_updated")
	var chunks: Vector2 = Vector2(visibility_range / chunk_size.x, visibility_range / chunk_size.y)
	for x in range(0, chunks.x + 1):
		for y in range(0, chunks.y + 1):
			_biomes.append(
				_create_chunk_renderer(
					Vector2(x, y) * chunk_size, terrain_inv_transform, terrain_size, terrain_pivot
				)
			)


func _on_stamp_updated(_image):
	for x in _biomes:
		x.generate(_sampling_provider)


func _on_data_region_changed(x, y, w, h, channel):
	#we can determine which chunks to update
	print("Region changed %d %d %d %d" % [x, y, w, h])
	for c in _biomes:
		if (
			c.chunk_position.x >= x
			&& c.chunk_position.x < x + w
			&& c.chunk_position.y >= y
			&& c.chunk_position.y < y + w
		):
			c.update_chunk()
