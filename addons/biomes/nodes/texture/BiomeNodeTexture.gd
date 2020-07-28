tool
extends 'res://addons/biomes/BiomeNode.gd'

var _file_dialog: FileDialog = null
var _preview_provider: EditorResourcePreview = null
var _imagepath = null


func _ready():
	set_slot(0, false, 0, Color(0, 0, 0), true, 3, Color(0, 0, 1))



func setup_dialogs(base_control):
	_file_dialog = FileDialog.new()
	_file_dialog.resizable = true
	_file_dialog.rect_min_size = Vector2(300, 200)
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.add_filter("*.png ; PNG Images")
	_file_dialog.add_filter("*.jpg ; JPEG Images")
	_file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	_file_dialog.hide()
	base_control.add_child(_file_dialog)


func _exit_tree():
	if _file_dialog != null:
		_file_dialog.queue_free()
		_file_dialog = null


func _preview_texture(image_path):
	var texture = load(image_path)
	$'VBoxContainer/Panel/TexturePreview'.texture = texture



func _on_EditorResourcePreview_preview_loaded(path, texture, userdata):
	if texture != null:
		$'VBoxContainer/Panel/TexturePreview'.texture = texture
	else:
		print("No preview available for ", path)


func _on_FileDialog_file_selected(fpath):
	$'VBoxContainer/HBoxContainer/PathLineEdit'.text = fpath
	_preview_texture(fpath)
	_imagepath = fpath


func _on_SelectButton_pressed():
	_file_dialog.popup_centered_ratio(0.5)


func generate_resource(output_slot: int):
	return _imagepath
