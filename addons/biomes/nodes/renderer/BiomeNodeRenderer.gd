tool
extends 'res://addons/biomes/BiomeNode.gd'

var _sampling_provider_script = preload("res://addons/biomes/scripts/PoissonDisc.gd")
var _biome_placement_nodes: Array = []

const BiomePlacementNode = preload("res://scripts/BiomePlacementNode.gd")

onready var _sampling_provider = _sampling_provider_script.new()

const SUBSET_PORT = 0
const DENSITY_PORT = 1

func _ready():
	set_slot(SUBSET_PORT, true, 2, Color(0, 1, 0), false, 3, Color(0, 1, 0))
	set_slot(DENSITY_PORT, true, 3, Color(0, 0, 1), false, 3, Color(0, 1, 0))
	set_slot(2, false, 10, Color(0, 0, 0), false, 3, Color(0, 1, 0))
	setup_biome()


func is_multiple_connections_enabled_on_slot(_slot: int):
	return _slot == SUBSET_PORT


func apply_texture(image: Image):
	var texture = ImageTexture.new()
	texture.create_from_image(image, 7)
	$'SamplingPreview'.texture = texture


func setup_biome():
	_sampling_provider.connect("stamp_updated", self, "_on_stamp_updated")


func _on_stamp_updated(image: Image):
	var points_one: Array = _sampling_provider.query_points_by_id(1)
	apply_texture(image)


func _on_GenerateButton_pressed():
	var ge: GraphEdit = get_parent()
	var childs = []
	var resources: Array = []
	var connected_graph = get_parent().get_connection_list()
	var density_path: String = ""
	for x in connected_graph:
		if x['to'] == self.name:
			childs.append(x)
	
	print("From Renderer:")
	print(childs)

	var id = 0
	for c in childs:
		var node = ge.get_node(c['from'])
		var resource = node.generate_resource(c['from_port'])
		if resource == null:
			continue
		if c['to_port'] == SUBSET_PORT:
			resource.id = id
			resources.append(resource)
			id += 1
		if c['to_port'] == DENSITY_PORT:
			density_path = resource
	print("From Renderer:")
	print(density_path)
	print(resources)
	_sampling_provider.setup_biome_placement_nodes(resources)
