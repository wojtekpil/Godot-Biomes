tool
extends Control

var _preview_provider: EditorResourcePreview = null


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
