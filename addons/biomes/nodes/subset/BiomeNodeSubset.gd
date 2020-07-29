tool
extends 'res://addons/biomes/BiomeNode.gd'

const LOD0_MESH_PORT = 0
const TRANSFORM_PORT = 5

func _ready():
	set_slot(LOD0_MESH_PORT, true, 1, Color(1, 0, 0), true, 2, Color(0, 1, 0))
	set_slot(1, true, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(2, true, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(3, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(4, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(TRANSFORM_PORT, true, 5, Color(0, 1, 1), false, 2, Color(0, 1, 0))
	set_slot(6, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))

func generate_resource(output_slot: int):
	var ge: GraphEdit = get_parent()
	var resource = null
	var transform = null
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
		if c['to_port'] == TRANSFORM_PORT:
			transform = node.generate_resource(c['from_port'])
	
	if resource == null:
		return null

	if transform == null:
		resource.scale = Vector3(1,1,1)
		resource.scale_variation = 0
	else:
		resource.scale = transform.scale
		resource.scale_variation = transform.scale_variation
	
	resource.density = $'HBoxContainer5/Frequency'.value
	resource.footprint = $'HBoxContainer4/Footprint'.value
	resource.color = $'HBoxContainer6/DebColor'.color
	return resource
