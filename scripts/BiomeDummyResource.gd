extends Resource

var _mesh1 = preload("res://assets/meshes/spheremesh.tres")
var _mesh2 = preload("res://assets/meshes/spheremesh2.tres")
var _mesh3 = preload("res://assets/meshes/spheremesh3.tres")

var BiomePlacementNode = preload("res://scripts/BiomePlacementNode.gd")


# Called when the node enters the scene tree for the first time.
func get_biome():
	var biome_placement_nodes = []
	var biome1 = BiomePlacementNode.new()
	biome1.id = 0
	biome1.footprint = 50
	biome1.density = 0.3
	biome1.color = Color(1, 0, 0)
	biome1.mesh = _mesh1
	biome_placement_nodes.append(biome1)

	var biome2 = BiomePlacementNode.new()
	biome2.id = 1
	biome2.footprint = 60
	biome2.density = 0.3
	biome2.color = Color(0, 1, 0)
	biome2.cast_shadow = true
	biome2.mesh = _mesh2
	biome_placement_nodes.append(biome2)

	var biome3 = BiomePlacementNode.new()
	biome3.id = 2
	biome3.footprint = 80
	biome3.density = 0.5
	biome3.color = Color(0, 0, 1)
	biome3.mesh = _mesh3
	biome3.cast_shadow = true
	biome_placement_nodes.append(biome3)
	return biome_placement_nodes
