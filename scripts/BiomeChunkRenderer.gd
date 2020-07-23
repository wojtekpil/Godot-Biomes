extends Spatial

export (Vector2) var chunk_size = Vector2(10, 10)

var _biomes: Array = []
var _sampling_provider_script = preload("res://scripts/PoissonDisc.gd")

var _mesh1 = preload("res://assets/meshes/spheremesh.tres")
var _mesh2 = preload("res://assets/meshes/spheremesh2.tres")
var _mesh3 = preload("res://assets/meshes/spheremesh3.tres")

var BiomePlacementNode = preload("res://scripts/BiomePlacementNode.gd")
var BiomeSubsetRenderer = preload("res://scripts/BiomeSubsetRenderer.gd")

#temporary sampling provider
onready var _sampling_provider = _sampling_provider_script.new()


func bootstrap_biome():
	var biome_placement_nodes = []
	var biome1 = BiomePlacementNode.new()
	biome1.id = 0
	biome1.footprint = 20
	biome1.density = 0.3
	biome1.color = Color(1, 0, 0)
	biome1.mesh = _mesh1
	biome_placement_nodes.append(biome1)

	var biome2 = BiomePlacementNode.new()
	biome2.id = 1
	biome2.footprint = 30
	biome2.density = 0.3
	biome2.color = Color(0, 1, 0)
	biome2.cast_shadow = true
	biome2.mesh = _mesh2
	biome_placement_nodes.append(biome2)

	var biome3 = BiomePlacementNode.new()
	biome3.id = 2
	biome3.footprint = 50
	biome3.density = 0.5
	biome3.color = Color(0, 0, 1)
	biome3.mesh = _mesh3
	biome3.cast_shadow = true
	biome_placement_nodes.append(biome3)

	_sampling_provider.setup_biome_placement_nodes(biome_placement_nodes)
	return biome_placement_nodes


func create_subset_renderer(biome_placement_node):
	var particles = BiomeSubsetRenderer.new()
	particles.id = biome_placement_node.id
	particles.mesh = biome_placement_node.mesh
	particles.chunk_size = chunk_size
	particles.stamp_size = _sampling_provider.stamp_size
	particles.enable_shadows = biome_placement_node.cast_shadow
	self.add_child(particles)
	
	return particles


# Called when the node enters the scene tree for the first time.
func _ready():
	var biome_placement_nodes = bootstrap_biome()
	for x in biome_placement_nodes:
		_biomes.append(create_subset_renderer(x))
	_sampling_provider.connect("stamp_updated", self, "_on_stamp_updated")


func _on_stamp_updated(_image):
	for x in _biomes:
		x.sampling_array = _sampling_provider.query_points_by_id(x.id)
		x.generate()
