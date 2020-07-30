extends MeshInstance

var _biome_placement_nodes: Array = []
var _sampling_provider_script = preload("res://addons/biomes/scripts/PoissonDisc.gd")

var Array2dToShader = preload("res://addons/biomes/scripts/runtime/Array2DToShader.gd")
var BiomePlacementNode = preload("res://addons/biomes/scripts/BiomePlacementNode.gd")

onready var _sampling_provider = _sampling_provider_script.new()


func apply_texture(image: Image):
	var texture = ImageTexture.new()
	texture.create_from_image(image, 7)
	material_override = SpatialMaterial.new()
	material_override.albedo_texture = texture


func bootstrap_biome():
	_biome_placement_nodes = []
	var biome1 = BiomePlacementNode.new()
	biome1.id = 0
	biome1.footprint = 20
	biome1.density = $'VBoxContainer/HBoxContainer/HSlider'.value
	biome1.color = Color(1, 0, 0)
	_biome_placement_nodes.append(biome1)

	var biome2 = BiomePlacementNode.new()
	biome2.id = 1
	biome2.footprint = 30
	biome2.density = $'VBoxContainer/HBoxContainer2/HSlider2'.value
	biome2.color = Color(0, 1, 0)
	_biome_placement_nodes.append(biome2)

	var biome3 = BiomePlacementNode.new()
	biome3.id = 2
	biome3.footprint = 50
	biome3.density = $'VBoxContainer/HBoxContainer3/HSlider3'.value
	biome3.color = Color(0, 0, 1)
	_biome_placement_nodes.append(biome3)
	_sampling_provider.setup_biome_placement_nodes(_biome_placement_nodes)


# Called when the node enters the scene tree for the first time.
func _ready():
	bootstrap_biome()
	_sampling_provider.connect("stamp_updated", self, "_on_stamp_updated")


func _on_stamp_updated(image: Image):
	var points_one: Array = _sampling_provider.query_points_by_id(1)
	var tex: ImageTexture = Array2dToShader.generate(points_one)
	apply_texture(image)


func _on_HSlider_value_changed(value):
	bootstrap_biome()


func _on_HSlider2_value_changed(value):
	bootstrap_biome()


func _on_HSlider3_value_changed(value):
	bootstrap_biome()
