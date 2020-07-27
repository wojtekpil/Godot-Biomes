extends Resource

var _mesh1 = preload("res://assets/meshes/spheremesh.tres")
var _mesh2 = preload("res://assets/meshes/spheremesh2.tres")
var _mesh3 = preload("res://assets/meshes/spheremesh3.tres")
var _mesh1_test = preload("res://assets/tests/grass2.mesh")
var _mesh2_test = preload("res://assets/tests/forest_tree_low.mesh")
var _mesh3_test = preload("res://assets/tests/PineTree1LOD0.mesh")
var _biome_density_map_path: String = "res://assets/textures/mask.png"
var _biome_density_map: Image
var _biome_placement_nodes: Array
var _biome_min_footprint: float = -1.0

var BiomePlacementNode = preload("res://scripts/BiomePlacementNode.gd")

func _init():
	var biome1 = BiomePlacementNode.new()
	biome1.id = 0
	biome1.footprint = 15
	biome1.density = 0.15
	biome1.color = Color(1, 0, 0)
	biome1.mesh = _mesh1_test
	biome1.cast_shadow = false
	biome1.scale = Vector3(0.4, 0.4, 0.4)
	biome1.scale_variation = 0.1
	_biome_placement_nodes.append(biome1)

	var biome2 = BiomePlacementNode.new()
	biome2.id = 1
	biome2.footprint = 40
	biome2.density = 0.4
	biome2.color = Color(0, 1, 0)
	biome2.cast_shadow = true
	biome2.mesh = _mesh2_test
	biome2.scale = Vector3(0.05, 0.05, 0.05)
	biome2.scale_variation = 0.3
	_biome_placement_nodes.append(biome2)

	var biome3 = BiomePlacementNode.new()
	biome3.id = 2
	biome3.footprint = 50
	biome3.density = 0.4
	biome3.color = Color(0, 0, 1)
	biome3.mesh = _mesh3_test
	biome3.cast_shadow = true
	biome3.scale = Vector3(0.08, 0.08, 0.08)
	biome3.scale_variation = 0.5
	_biome_placement_nodes.append(biome3)

	_biome_min_footprint= _biome_placement_nodes[0].footprint
	for x in _biome_placement_nodes:
		_biome_min_footprint = min(_biome_min_footprint, x.footprint)

	_biome_density_map = Image.new()
	_biome_density_map.load(_biome_density_map_path)

func get_densitymap():
	return _biome_density_map


func get_biome_placement_nodes():
	return _biome_placement_nodes

func get_min_footprint():
	return _biome_min_footprint
