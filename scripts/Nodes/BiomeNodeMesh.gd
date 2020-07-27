tool
extends GraphNode

var _file_dialog: FileDialog = null
var _preview_provider: EditorResourcePreview = null


func set_preview_provider(provider: EditorResourcePreview):
	assert(_preview_provider == null)
	assert(provider != null)
	_preview_provider = provider
	#_preview_provider.connect("preview_invalidated", self, "_on_EditorResourcePreview_preview_invalidated")


func setup_dialogs(base_control):
	_file_dialog = FileDialog.new()
	_file_dialog.rect_min_size = Vector2(300, 200)
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.add_filter("*.mesh; Mesh files")
	_file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	_file_dialog.hide()
	base_control.add_child(_file_dialog)


func _exit_tree():
	if _file_dialog != null:
		_file_dialog.queue_free()
		_file_dialog = null


func _preview_mesh(mesh_path):
	# TODO I need scene thumbnails from the editor
	var defult_texture = get_icon("PackedScene", "EditorIcons")
	$'VBoxContainer/MeshPreview'.texture = defult_texture
	_preview_provider.queue_resource_preview(
		mesh_path, self, "_on_EditorResourcePreview_preview_loaded", null
	)


func _on_EditorResourcePreview_preview_loaded(path, texture, userdata):
	if texture != null:
		$'VBoxContainer/MeshPreview'.texture = texture
	else:
		print("No preview available for ", path)


func _on_FileDialog_file_selected(fpath):
	$'VBoxContainer/HBoxContainer/PathLineEdit'.text = fpath
	_preview_mesh(fpath)


func _on_SelectButton_pressed():
	_file_dialog.show()
