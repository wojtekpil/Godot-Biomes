tool
extends Control

var BiomeNode = load("res://addons/wojtekpil.biomes/nodes/BiomeNode.gd")
var BiomeNodeMesh = load("res://addons/wojtekpil.biomes/nodes/mesh/BiomeNodeMesh.tscn")
var BiomeNodeTexture = load("res://addons/wojtekpil.biomes/nodes/texture/BiomeNodeTexture.tscn")
var BiomeNodeZylannTexture = load("res://addons/wojtekpil.biomes/nodes/zylann_texture/BiomeNodeZylannTexture.tscn")
var BiomeNodeSubset = load("res://addons/wojtekpil.biomes/nodes/subset/BiomeNodeSubset.tscn")
var BiomeNodeTransform = load("res://addons/wojtekpil.biomes/nodes/transform/BiomeNodeTransform.tscn")
var BiomeNodeRenderer = load("res://addons/wojtekpil.biomes/nodes/renderer/BiomeNodeRenderer.tscn")

var _file_save_dialog: FileDialog = null
var _file_load_dialog: FileDialog = null
var _preview_provider: EditorResourcePreview = null
onready var _ge: GraphEdit = $'BiomeGraphEdit'


func set_preview_provider(provider: EditorResourcePreview):
	assert(_preview_provider == null)
	assert(provider != null)
	_preview_provider = provider


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_dialogs(self)


"""
Creates a node using the provided model and add it as child which makes it visible and editable
Based on HungryProton's concept_graph
"""


func create_node(node_script: String, data := {}, graph: GraphEdit = null):
	var new_node_packed = load(node_script)
	if not new_node_packed:
		return null

	assert(new_node_packed.can_instance(), "Cannot create instance of node")
	var new_node = new_node_packed.instance()

	new_node.name = data["name"]

	if data.has("offset_x") && data.has("offset_y"):
		new_node.offset = Vector2(data["offset_x"], data["offset_y"])
	else:
		new_node.offset = Vector2(250, 150)

	graph.add_child(new_node, true)
	#_connect_node_signals(new_node)

	if new_node.has_method("set_preview_provider"):
		new_node.set_preview_provider(_preview_provider)
	if new_node.has_method("setup_dialogs"):
		new_node.call_deferred("setup_dialogs", self)

	if data.has("data") && data["data"] != null:
		new_node.restore_custom_data(data["data"])

	return new_node


"""
Opens a cgraph file, reads its contents and recreate a node graph from there
Based on HungryProton's concept_graph
"""


func load_from_file(path: String):
	if not path or path == "":
		return

	var graph_node = $'BiomeGraphEdit'

	# Open the file and read the contents
	var file = File.new()
	file.open(path, File.READ)
	var json = JSON.parse(file.get_as_text())
	if not json or not json.result:
		print("Failed to parse the template file")
		return  # Template file is either empty or not a valid Json. Ignore

	# Abort if the file doesn't have node data
	var graph: Dictionary = json.result
	if not graph.has("nodes"):
		return

	# For each node found in the template file
	for node_data in graph["nodes"]:
		if node_data.has("type"):
			var type = node_data["type"]
			create_node(type, node_data, graph_node)

	for c in graph["connections"]:
		# TODO: convert the to/from ports stored in file to actual port
		graph_node.connect_node(c["from"], c["from_port"], c["to"], c["to_port"])
		var n = graph_node.get_node(c["to"])
		if not n:
			print("Can't find node ", c["to"])
			continue

"""
Based on HungryProton's concept_graph
"""


func save_to_file(path: String):
	var graph_node = $'BiomeGraphEdit'
	var graph := {}
	graph["connections"] = graph_node.get_connection_list()
	graph["nodes"] = []

	for c in graph_node.get_children():
		if c is BiomeNode:
			var node = {}
			node["name"] = c.name
			node["type"] = c.filename
			node["data"] = c.export_custom_data()
			node["offset_x"] = c.offset.x
			node["offset_y"] = c.offset.y
			graph["nodes"].append(node)

	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(graph))
	file.close()


func _on_AddMeshNodeButton_pressed():
	assert(BiomeNodeMesh, "Failed to load node")
	assert(BiomeNodeMesh.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeMesh.instance()
	assert(node is BiomeNode)
	node.offset += Vector2(20, 20)
	node.set_preview_provider(_preview_provider)
	node.call_deferred("setup_dialogs", self)
	_ge.add_child(node)


func _on_AddSubsetNodeButton_pressed():
	assert(BiomeNodeSubset, "Failed to load node")
	assert(BiomeNodeSubset.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeSubset.instance()
	assert(node is BiomeNode)
	node.offset += Vector2(20, 20)
	_ge.add_child(node)


func _on_AddRendererNodeButton_pressed():
	assert(BiomeNodeRenderer, "Failed to load node")
	assert(BiomeNodeRenderer.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeRenderer.instance()
	assert(node is BiomeNode)
	node.offset += Vector2(20, 20)
	node.call_deferred("setup_dialogs", self)
	_ge.add_child(node)


func _on_AddTextureNodeButton_pressed():
	assert(BiomeNodeTexture, "Failed to load node")
	assert(BiomeNodeTexture.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeTexture.instance()
	assert(node is BiomeNode)
	node.offset += Vector2(20, 20)
	node.call_deferred("setup_dialogs", self)
	_ge.add_child(node)


func _on_AddZylannTextureNodeButton_pressed():
	assert(BiomeNodeZylannTexture, "Failed to load node")
	assert(BiomeNodeZylannTexture.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeZylannTexture.instance()
	assert(node is BiomeNode)
	node.offset += Vector2(20, 20)
	_ge.add_child(node)


func _on_AddTransformNodeButton_pressed():
	assert(BiomeNodeTransform, "Failed to load node")
	assert(BiomeNodeTransform.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeTransform.instance()
	assert(node is BiomeNode)
	node.offset += Vector2(20, 20)
	_ge.add_child(node)


func _on_BiomeGraphEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int):
	if from == to:
		return

	var node = _ge.get_node(to)
	if not node.is_multiple_connections_enabled_on_slot(to_slot):
		for c in _ge.get_connection_list():
			if c["to"] == to and c["to_port"] == to_slot:
				_ge.disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
				break

	_ge.connect_node(from, from_slot, to, to_slot)


func setup_dialogs(base_control):
	_file_save_dialog = FileDialog.new()
	_file_save_dialog.resizable = true
	_file_save_dialog.rect_min_size = Vector2(300, 200)
	_file_save_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_save_dialog.mode = FileDialog.MODE_SAVE_FILE
	_file_save_dialog.add_filter("*.bgraph ; Biome graph")
	_file_save_dialog.connect("file_selected", self, "_on_FileSaveDialog_file_selected")
	_file_save_dialog.hide()
	base_control.add_child(_file_save_dialog)

	_file_load_dialog = FileDialog.new()
	_file_load_dialog.resizable = true
	_file_load_dialog.rect_min_size = Vector2(300, 200)
	_file_load_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_load_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_load_dialog.add_filter("*.bgraph ; Biome graph")
	_file_load_dialog.connect("file_selected", self, "_on_FileOpenDialog_file_selected")
	_file_load_dialog.hide()
	base_control.add_child(_file_load_dialog)


func _on_FileSaveDialog_file_selected(fpath):
	save_to_file(fpath)


func _on_FileOpenDialog_file_selected(fpath):
	load_from_file(fpath)


func _on_SaveButton_pressed():
	_file_save_dialog.popup_centered_ratio(0.5)


func _on_LoadButton_pressed():
	_file_load_dialog.popup_centered_ratio(0.5)
