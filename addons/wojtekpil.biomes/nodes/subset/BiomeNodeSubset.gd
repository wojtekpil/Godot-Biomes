tool
extends 'res://addons/wojtekpil.biomes/nodes/BiomeNode.gd'

const LOD0_MESH_PORT = 0
const LOD1_MESH_PORT = 1
const LOD2_MESH_PORT = 2
const TRANSFORM_PORT = 3


func _ready():
	set_slot(0, true, 1, Color(1, 0, 0), true, 2, Color(0, 1, 0))
	set_slot(1, true, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(2, true, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(3, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(4, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(5, false, 5, Color(0, 1, 1), false, 2, Color(0, 1, 0))
	set_slot(6, true, 5, Color(0, 1, 1), false, 2, Color(0, 1, 0))
	set_slot(7, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))


func generate_resource(output_slot: int):
	var ge: GraphEdit = get_parent()
	var resource = null
	var mesh1 = null
	var mesh2 = null
	var transform_mesh = null
	#only one output
	var childs = []
	var connected_graph = get_parent().get_connection_list()
	for x in connected_graph:
		if x['to'] == self.name:
			childs.append(x)

	print("From Subset:")
	print(childs)

	for c in childs:
		var node = ge.get_node(c['from'])
		if c['to_port'] == LOD0_MESH_PORT:
			resource = node.generate_resource(c['from_port'])
		if c['to_port'] == LOD1_MESH_PORT:
			mesh1 = node.generate_resource(c['from_port'])
		if c['to_port'] == LOD2_MESH_PORT:
			mesh2 = node.generate_resource(c['from_port'])
		if c['to_port'] == TRANSFORM_PORT:
			transform_mesh = node.generate_resource(c['from_port'])

	if resource == null:
		return null

	if mesh1 != null:
		resource.mesh1 = mesh1.mesh
	if mesh2 != null:
		resource.mesh2 = mesh2.mesh

	if transform_mesh == null:
		resource.scale = Vector3(1, 1, 1)
		resource.scale_variation = 0
	else:
		resource.scale = transform_mesh.scale
		resource.scale_variation = transform_mesh.scale_variation

	resource.density = $'HBoxContainer5/Frequency'.value
	resource.footprint = $'HBoxContainer4/Footprint'.value
	resource.color = $'HBoxContainer6/DebColor'.color
	resource.cast_shadow = $'HBoxContainer7/ShadowsButton'.pressed
	return resource


func restore_custom_data(data := {}):
	if "density" in data:
		$'HBoxContainer5/Frequency'.value = data['density']
	if "footprint" in data:
		$'HBoxContainer4/Footprint'.value = data['footprint']
	if "color_r" in data && 'color_g' in data && 'color_b' in data && 'color_a' in data:
		var color = Color(
			float(data['color_r']),
			float(data['color_g']),
			float(data['color_b']),
			float(data['color_a'])
		)
		$'HBoxContainer6/DebColor'.color = color
	if "cast_shadow" in data:
		$'HBoxContainer7/ShadowsButton'.pressed = data['cast_shadow']


func export_custom_data():
	return {
		'density': $'HBoxContainer5/Frequency'.value,
		'footprint': $'HBoxContainer4/Footprint'.value,
		'color_r': $'HBoxContainer6/DebColor'.color.r,
		'color_g': $'HBoxContainer6/DebColor'.color.g,
		'color_b': $'HBoxContainer6/DebColor'.color.b,
		'color_a': $'HBoxContainer6/DebColor'.color.a,
		'cast_shadow': $'HBoxContainer7/ShadowsButton'.pressed
	}
