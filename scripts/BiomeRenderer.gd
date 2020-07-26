extends Spatial

export (Vector2) var chunk_size = Vector2(10, 10)
export (NodePath) var terrain = null

var _biomes: Array = []
var _sampling_provider_script = preload("res://scripts/PoissonDisc.gd")

var BiomeChunkRenderer = preload("res://scripts/BiomeChunkRenderer.gd")
var BiomeDummyResource = preload("res://scripts/BiomeDummyResource.gd")

onready var _biome_resource = BiomeDummyResource.new()
onready var _sampling_provider = _sampling_provider_script.new()
onready var _terrain = get_node(terrain)


func bootstrap_biome():
	var biome_placement_nodes = _biome_resource.get_biome_placement_nodes()
	_sampling_provider.setup_biome_placement_nodes(biome_placement_nodes)


func create_chunk_renderer(chunk_position: Vector2, terrain_inv_transform: Transform):
	var chunk = BiomeChunkRenderer.new()
	chunk.chunk_size = chunk_size
	chunk.chunk_position = chunk_position
	chunk.biome_resource = _biome_resource
	chunk.terrain_inv_transform = terrain_inv_transform

	self.add_child(chunk)
	return chunk


# Called when the node enters the scene tree for the first time.
func _ready():
	var terrain_inv_transform: Transform = _terrain.transform.affine_inverse()

	bootstrap_biome()
	_sampling_provider.connect("stamp_updated", self, "_on_stamp_updated")
	for x in range(-1, 2):
		for y in range(-1, 2):
			_biomes.append(create_chunk_renderer(Vector2(x, y) * chunk_size, terrain_inv_transform))


func _on_stamp_updated(_image):
	for x in _biomes:
		x.generate(_sampling_provider)
