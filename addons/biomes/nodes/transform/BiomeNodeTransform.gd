tool
extends 'res://addons/biomes/nodes/BiomeNode.gd'

const BiomePlacementNode = preload("res://addons/biomes/scripts/BiomePlacementNode.gd")


func _ready():
	set_slot(0, false, 1, Color(1, 0, 0), true, 5, Color(0, 1, 1))
	set_slot(1, false, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(2, false, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(3, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))

func generate_resource(output_slot: int):
	var resource = BiomePlacementNode.new()
	var scale: Vector3 = Vector3()
	scale.x = $'HBoxContainer4/ScaleX'.value
	scale.y = $'HBoxContainer7/ScaleY'.value
	scale.z = $'HBoxContainer8/ScaleZ'.value
	resource.scale = scale
	resource.scale_variation = $'HBoxContainer5/ScaleVar'.value
	
	return resource