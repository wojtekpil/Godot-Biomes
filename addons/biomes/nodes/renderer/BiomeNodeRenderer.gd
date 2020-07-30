tool
extends 'res://addons/biomes/nodes/BiomeNode.gd'

var _sampling_provider_script = preload("res://addons/biomes/scripts/PoissonDisc.gd")
var _biome_placement_nodes: Array = []
var _resources: Array = []
var _density_path: String = ""
var _file_dialog: FileDialog = null

const BiomePlacementNode = preload("res://addons/biomes/scripts/BiomePlacementNode.gd")
const BiomeResource = preload("res://addons/biomes/scripts/BiomeResource.gd")

onready var _sampling_provider = _sampling_provider_script.new()

const SUBSET_PORT = 0
const DENSITY_PORT = 1


func _ready():
	set_slot(0, true, 2, Color(0, 1, 0), false, 3, Color(0, 1, 0))
	set_slot(1, true, 3, Color(0, 0, 1), false, 3, Color(0, 1, 0))
	set_slot(2, false, 10, Color(0, 0, 0), false, 3, Color(0, 1, 0))
	setup_biome()


func setup_dialogs(base_control):
	_file_dialog = FileDialog.new()
	_file_dialog.resizable = true
	_file_dialog.rect_min_size = Vector2(300, 200)
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	_file_dialog.add_filter("*.tres; resource files")
	_file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	_file_dialog.hide()
	base_control.add_child(_file_dialog)

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


func generate_biome():
	var ge: GraphEdit = get_parent()
	var childs = []
	var connected_graph = get_parent().get_connection_list()
	_resources = []
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
			_resources.append(resource)
			id += 1
		if c['to_port'] == DENSITY_PORT:
			_density_path = resource
	print("From Renderer:")
	print(_density_path)
	print(_resources)
	_sampling_provider.setup_biome_placement_nodes(_resources)


func _on_GenerateButton_pressed():
	generate_biome()


func _on_SaveResourceButton_pressed():
	if _resources.size() == 0:
		generate_biome()
	_file_dialog.popup_centered_ratio(0.5)


func _on_FileDialog_file_selected(fpath):
	var b_res = BiomeResource.new()
	b_res.biome_subsets = _resources
	b_res.biome_density_map_path = _density_path
	ResourceSaver.save(fpath, b_res)