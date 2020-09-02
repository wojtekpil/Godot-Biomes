extends Control

export (NodePath) var biome_nodepath

onready var _biome = get_node(biome_nodepath)

var _lod0_chunks = 0
var _lod1_chunks = 0
var _lod2_chunks = 0

var _subsets: Dictionary = {}
var _subsets_meshes_vertices : Dictionary = {}

func _ready():
	get_avaible_subsets()

func get_count_vert(mesh):
	if mesh == null:
		return 0
	return mesh.surface_get_arrays(0)[0].size()

func get_avaible_subsets():
	var subsets = _biome.biome.biome_subsets
	for x in subsets:
		var mesh_name = x.mesh.resource_path.get_file()
		_subsets[mesh_name] = {}
		_subsets_meshes_vertices[mesh_name] = {}
		var vertc = get_count_vert(x.mesh)
		_subsets_meshes_vertices[mesh_name][0] = vertc
		vertc = get_count_vert(x.mesh1)
		_subsets_meshes_vertices[mesh_name][1] = vertc
		vertc = get_count_vert(x.mesh2)
		_subsets_meshes_vertices[mesh_name][2] = vertc


func update_chunks_lods():
	_lod0_chunks = {'all': 0, 'visible': 0}
	_lod1_chunks = {'all': 0, 'visible': 0}
	_lod2_chunks = {'all': 0, 'visible': 0}
	var biomes = _biome.get_biomes()
	for x in biomes:
		match biomes[x].lod:
			0:
				_lod0_chunks['all'] += 1
				_lod0_chunks['visible'] += 1 if biomes[x].visible else 0
			1:
				_lod1_chunks['all'] += 1
				_lod1_chunks['visible'] += 1 if biomes[x].visible else 0
			2:
				_lod2_chunks['all'] += 1
				_lod2_chunks['visible'] += 1 if biomes[x].visible else 0


func update_subsets_counts():
	for x in _subsets:
		_subsets[x] = {'visible': 0, 'all': 0, 'vert': 0}

	var biomes = _biome.get_biomes()
	for x in biomes:
		for y in biomes[x].get_subsets():
			var mesh_name = y.mesh.resource_path.get_file()
			if biomes[x].visible == true:
				_subsets[mesh_name]['visible'] += y.get_visible_count()
				_subsets[mesh_name]['vert'] += _subsets_meshes_vertices[mesh_name][y.lod] * y.get_visible_count()
			_subsets[mesh_name]['all'] += y.get_visible_count()


func update_lods_text():
	$"Panel/VBoxContainer/MainStats/chunksLod0".text = str(_lod0_chunks.get('visible',0)) + " (" + str(_lod0_chunks.get('all',0)) + ")"
	$"Panel/VBoxContainer/MainStats/chunksLod1".text = str(_lod1_chunks.get('visible',0)) + " (" + str(_lod1_chunks.get('all',0)) + ")"
	$"Panel/VBoxContainer/MainStats/chunksLod2".text = str(_lod2_chunks.get('visible',0)) + " (" + str(_lod2_chunks.get('all',0)) + ")"

func update_subsets_text():
	var node_stats = $"Panel/VBoxContainer/NodesStats"
	for x in node_stats.get_children():
		node_stats.remove_child(x)
		x.queue_free()

	for x in _subsets:
		var label = Label.new()
		label.text = x
		node_stats.add_child(label)
		var lvalue = Label.new()
		lvalue.text = str(_subsets[x].get('visible',0)) + " (" + str(_subsets[x].get('all',0)) + ")"
		node_stats.add_child(lvalue)
		var rvalue = Label.new()
		rvalue.text = "[" + str(_subsets[x].get('vert',0)) + "]"
		node_stats.add_child(rvalue)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _biome == null:
		return
	update_chunks_lods()
	update_lods_text()
	update_subsets_counts()
	update_subsets_text()
