tool
extends 'res://addons/wojtekpil.biomes/nodes/BiomeNode.gd'

const BiomePlacementNode = preload("res://addons/wojtekpil.biomes/scripts/BiomePlacementNode.gd")


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


func restore_custom_data(data := {}):
	if "scale_x" in data:
		$'HBoxContainer4/ScaleX'.value = data['scale_x']
	if "scale_y" in data:
		$'HBoxContainer7/ScaleY'.value = data['scale_y']
	if "scale_z" in data:
		$'HBoxContainer8/ScaleZ'.value = data['scale_z']
	if "scale_var" in data:
		$'HBoxContainer5/ScaleVar'.value = data['scale_var']


func export_custom_data():
	return {
		'scale_x': $'HBoxContainer4/ScaleX'.value,
		'scale_y': $'HBoxContainer7/ScaleY'.value,
		'scale_z': $'HBoxContainer8/ScaleZ'.value,
		'scale_var': $'HBoxContainer5/ScaleVar'.value
	}
