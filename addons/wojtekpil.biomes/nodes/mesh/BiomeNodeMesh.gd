tool
extends 'res://addons/wojtekpil.biomes/nodes/BiomeNode.gd'

var _file_dialog: FileDialog = null
var _preview_provider: EditorResourcePreview = null
var _meshfile = null

const BiomePlacementNode = preload("res://addons/wojtekpil.biomes/scripts/BiomePlacementNode.gd")


func _ready():
	set_slot(0, false, 0, Color(0, 0, 0), true, 1, Color(1, 0, 0))


func set_preview_provider(provider: EditorResourcePreview):
	assert(_preview_provider == null)
	assert(provider != null)
	_preview_provider = provider


func setup_dialogs(base_control):
	_file_dialog = FileDialog.new()
	_file_dialog.resizable = true
	_file_dialog.rect_min_size = Vector2(300, 200)
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.add_filter("*.mesh; Mesh files")
	_file_dialog.add_filter("*.tres; Mesh resource files")
	_file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	_file_dialog.hide()
	base_control.add_child(_file_dialog)


func _exit_tree():
	if _file_dialog != null:
		_file_dialog.queue_free()
		_file_dialog = null


func _preview_mesh(mesh_path):
	var defult_texture = get_icon("PackedScene", "EditorIcons")
	$'VBoxContainer/Panel/MeshPreview'.texture = defult_texture
	_preview_provider.queue_resource_preview(
		mesh_path, self, "_on_EditorResourcePreview_preview_loaded", null
	)


func _on_EditorResourcePreview_preview_loaded(path, texture, userdata):
	if texture != null:
		$'VBoxContainer/Panel/MeshPreview'.texture = texture
	else:
		print("No preview available for ", path)


func _load_mesh(fpath):
	$'VBoxContainer/HBoxContainer/PathLineEdit'.text = fpath
	_preview_mesh(fpath)
	_meshfile = fpath


func _on_FileDialog_file_selected(fpath):
	_load_mesh(fpath)


func _on_SelectButton_pressed():
	_file_dialog.popup_centered_ratio(0.5)


func generate_resource(output_slot: int):
	var ge: GraphEdit = get_parent()
	var resource = BiomePlacementNode.new()

	if _meshfile == null:
		return null

	resource.mesh = load(_meshfile)
	return resource


func restore_custom_data(data := {}):
	if "meshfile" in data:
		_load_mesh(data['meshfile'])


func export_custom_data():
	return {'meshfile': _meshfile}
