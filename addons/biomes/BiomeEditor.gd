tool
extends Control

var BiomeNodeMesh = load("res://addons/biomes/nodes/mesh/BiomeNodeMesh.tscn")
var BiomeNodeTexture = load("res://addons/biomes/nodes/texture/BiomeNodeTexture.tscn")
var BiomeNodeSubset = load("res://addons/biomes/nodes/subset/BiomeNodeSubset.tscn")
var BiomeNodeRenderer = load("res://addons/biomes/nodes/renderer/BiomeNodeRenderer.tscn")

var _preview_provider: EditorResourcePreview = null
onready var _ge: GraphEdit = $'BiomeGraphEdit'


func set_preview_provider(provider: EditorResourcePreview):
	assert(_preview_provider == null)
	assert(provider != null)
	_preview_provider = provider


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AddMeshNodeButton_pressed():
	assert(BiomeNodeMesh, "Failed to load node")
	assert(BiomeNodeMesh.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeMesh.instance()
	assert(node is GraphNode)
	node.offset += Vector2(20, 20)
	node.set_preview_provider(_preview_provider)
	node.call_deferred("setup_dialogs", self)
	_ge.add_child(node)


func _on_AddSubsetNodeButton_pressed():
	assert(BiomeNodeSubset, "Failed to load node")
	assert(BiomeNodeSubset.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeSubset.instance()
	assert(node is GraphNode)
	node.offset += Vector2(20, 20)
	_ge.add_child(node)


func _on_AddRendererNodeButton_pressed():
	assert(BiomeNodeRenderer, "Failed to load node")
	assert(BiomeNodeRenderer.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeRenderer.instance()
	assert(node is GraphNode)
	node.offset += Vector2(20, 20)
	_ge.add_child(node)


func _on_AddTextureNodeButton_pressed():
	assert(BiomeNodeTexture, "Failed to load node")
	assert(BiomeNodeTexture.can_instance(), "Cannot create instance of node")
	var node = BiomeNodeTexture.instance()
	assert(node is GraphNode)
	node.offset += Vector2(20, 20)
	node.call_deferred("setup_dialogs", self)
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
