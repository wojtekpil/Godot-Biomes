tool
extends Spatial

export (Resource) var biome = null
export (Vector2) var chunk_size = Vector2(32, 32)
export (float) var visibility_range = 10
export (float) var lod0_range = 5
export (NodePath) var terrain = null

enum MESH_RENDER { Multimesh, Particles, Particles_GPU_density }
export (MESH_RENDER) var mesh_renderer = MESH_RENDER.Multimesh

var _biomes: Dictionary = {}
var _chunks_free_pool: Array = []
var _viewer_pos_world: Vector3 = Vector3(0,0,0)

var BiomeChunkRenderer = preload("res://addons/wojtekpil.biomes/scripts/runtime/BiomeChunkRenderer.gd")
var BiomeResource = preload("res://addons/wojtekpil.biomes/scripts/BiomeResource.gd")

onready var _biome_resource = BiomeResource.new()
onready var _terrain = get_node(terrain)


func _bootstrap_biome():
	_biome_resource.load(biome)


func _create_chunk_renderer(
	chunk_position: Vector2,
	terrain_inv_transform: Transform,
	terrain_size: Vector2,
	terrain_pivot: Vector2,
	lod: int
):
	var chunk = null
	var is_new = true
	if len(_chunks_free_pool) != 0:
		chunk = _chunks_free_pool[-1]
		_chunks_free_pool.pop_back()
		is_new = false
	else:
		chunk = BiomeChunkRenderer.new()
	chunk.chunk_size = chunk_size
	chunk.chunk_position = chunk_position
	chunk.biome_resource = _biome_resource
	chunk.terrain_inv_transform = terrain_inv_transform
	chunk.mesh_renderer = mesh_renderer
	chunk.terrain_size = terrain_size
	chunk.terrain_pivot = terrain_pivot
	chunk.terrain = _terrain
	if is_new:
		chunk.call_deferred("generate")
		self.add_child(chunk)
	else:
		chunk.update_chunk()
	return chunk


func _get_terrain_inv_transform(terrain: Node):
	if terrain is MeshInstance:
		return _terrain.transform.affine_inverse()
	if "HTerrainData" in terrain:  #its Zylann's
		var gt = terrain.get_internal_transform()
		return gt.affine_inverse()


func _get_terrain_size(terrain: Node):
	if terrain is MeshInstance:
		return _terrain.mesh.size
	if "HTerrainData" in terrain:  #its Zylann's
		var map_res = terrain.get_data().get_resolution()
		var map_scale = terrain.map_scale
		return Vector2(map_scale.x * map_res, map_scale.z * map_res)


func _get_terrain_pivot(terrain: Node):
	if terrain is MeshInstance:
		return _terrain.mesh.size / 2.0
	if "HTerrainData" in terrain:  #its Zylann's
		return Vector2(0, 0)


func _setup_live_update(terrain: Node):
	if "HTerrainData" in terrain:  #its Zylann's
		terrain.get_data().connect("region_changed", self, "_on_data_region_changed")


func update_viewer_position(camera: Camera):
	if camera == null:
		var viewport := get_viewport()
		if viewport != null:
			camera = viewport.get_camera()

	if camera == null:
		return
	_viewer_pos_world = camera.global_transform.origin


# Called when the node enters the scene tree for the first time.
func _ready():
	if biome == null || _terrain == null:
		print("No biome or terrain selected")
		return
	_bootstrap_biome()
	_setup_live_update(_terrain)
	_process(0)

func _process(_delta: float):
	if not Engine.is_editor_hint():
		update_viewer_position(null)
	if biome == null || _terrain == null:
		return
	update(_viewer_pos_world)


func _calculate_lod(cr0, viewer_cx, viewer_cz, chunk_pos):
	if abs(chunk_pos.x - viewer_cx) > cr0 || abs(chunk_pos.y - viewer_cz) > cr0:
		return  1
	else:
		return 0


func update(viewer_pos: Vector3):
	var terrain_inv_transform: Transform = _get_terrain_inv_transform(_terrain)
	var terrain_size: Vector2 = _get_terrain_size(_terrain)
	var terrain_pivot: Vector2 = _get_terrain_pivot(_terrain)

	var local_viewer_pos = (
		viewer_pos
		- _terrain.translation
		+ Vector3(terrain_pivot.x, 0, terrain_pivot.y)
	)
	var viewer_cx = local_viewer_pos.x / chunk_size.x
	var viewer_cz = local_viewer_pos.z / chunk_size.y

	var cr = int(visibility_range) / chunk_size.x + 1

	var cr0 = int(lod0_range) / chunk_size.x + 1

	var cmin_x = viewer_cx - cr
	var cmin_z = viewer_cz - cr
	var cmax_x = viewer_cx + cr
	var cmax_z = viewer_cz + cr

	var terrain_chunks_x = int(terrain_size.x / chunk_size.x)
	var terrain_chunks_z = int(terrain_size.y / chunk_size.y)

	if cmin_x < 0:
		cmin_x = 0
	if cmin_z < 0:
		cmin_z = 0
	if cmax_x > terrain_chunks_x:
		cmax_x = terrain_chunks_x
	if cmax_z > terrain_chunks_z:
		cmax_z = terrain_chunks_z


	for cz in range(cmin_z, cmax_z + 1):
		for cx in range(cmin_x, cmax_x + 1):
			var cpos2d = Vector2(cx, cz)
			var lod = _calculate_lod(cr0, viewer_cx, viewer_cz, cpos2d)
			if _biomes.has(cpos2d):
				_biomes.get(cpos2d).update_lod(lod)
				continue
			var chunk = _create_chunk_renderer(
				cpos2d * chunk_size, terrain_inv_transform, terrain_size, terrain_pivot, lod
			)
			chunk.visible = true
			_biomes[cpos2d] = chunk

	var to_recycle: Array = []
	#we cant remove biome from dictionary when iterating so we create a list helper
	for bi in _biomes:
		if bi.x >= int(cmin_x) && bi.x < int(cmax_x) + 1 && bi.y >= int(cmin_z) && bi.y < int(cmax_z) + 1:
			continue
		to_recycle.append(bi)
	for cpos2d in to_recycle:
		var chunk = _biomes[cpos2d]
		_biomes.erase(cpos2d)
		chunk.visible = false
		_chunks_free_pool.append(chunk)


func _on_data_region_changed(x, y, w, h, channel):
	#we can determine which chunks to update
	for bi in _biomes:
		var c = _biomes[bi]
		if (
			c.chunk_position.x >= x
			&& c.chunk_position.x < x + w
			&& c.chunk_position.y >= y
			&& c.chunk_position.y < y + w
		):
			c.call_deferred("update_chunk")
