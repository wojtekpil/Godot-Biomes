tool
extends 'res://addons/biomes/BiomeNode.gd'

const LOD0_MESH = 0

func _ready():
	set_slot(LOD0_MESH, true, 1, Color(1, 0, 0), true, 2, Color(0, 1, 0))
	set_slot(1, true, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(2, true, 1, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(3, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))
	set_slot(4, false, 5, Color(1, 0, 0), false, 2, Color(0, 1, 0))

func generate_resource(output_slot: int):
	var ge: GraphEdit = get_parent()
	var resource = null
	#only one output
	var childs = []
	var connected_graph = get_parent().get_connection_list()
	for x in connected_graph:
		if x['to'] == self.name:
			childs.append(x)

	print("From Subset:")
	print(childs)

	for c in childs:
		#only LOD0 for now
		if c['to_port'] != LOD0_MESH:
			continue
		var node = ge.get_node(c['from'])
		resource = node.generate_resource(c['from_port'])
	
	if resource == null:
		return null
	
	resource.density = $'HBoxContainer5/Frequency'.value
	resource.footprint = $'HBoxContainer4/Footprint'.value
	resource.color = $'HBoxContainer6/DebColor'.color
	return resource
