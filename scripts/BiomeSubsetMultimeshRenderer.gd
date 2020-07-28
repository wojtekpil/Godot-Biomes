extends MultiMeshInstance

export (Array) var sampling_array = []
export (bool) var enable_shadows = false
export (Image) var densitymap
export (int) var id = -1
export (int) var maximum_instance_count = 100
export (Mesh) var mesh = preload("res://assets/meshes/spheremesh.tres")
export (Transform) var terrain_inv_transform
export (Vector2) var chunk_size = Vector2(10, 10)
export (Vector2) var chunk_position = Vector2(0, 0)
export (Vector2) var stamp_size = Vector2(256, 256)
export (float) var dithering_scale = 10.0
export (Vector3) var object_scale = Vector3(1, 1, 1)
export (float) var object_scale_variation = 0.3
export (float) var object_rotation_variation = 3.14 * 2.0

var _visibility_height_range = 800
var _semaphore: Semaphore
var _thread: Thread
var _running = true

var Array2dToShader = preload("res://scripts/Array2DToShader.gd")
var ParticlePlacementShader = preload("res://shaders/particle_placer.shader")
var ParticlePlacementShaderGPU = preload("res://shaders/particle_placer_gpu.shader")


func _dither_density(fade: float, pos: Vector2):
	var limit: Array = [
		0.5625,
		0.1875,
		0.6875,
		0.8125,
		0.3125,
		0.9375,
		0.0625,
		0.4375,
		0.25,
		0.75,
		0.125,
		0.625,
		1.0,
		0.5,
		0.875,
		0.375
	]
	var x: int = int(pos.x) % 4
	var y: int = int(pos.y) % 4
	var index: int = x + y * 4
	return fade < limit[index]


func _is_in_range(pixel: Vector2, size: Vector2):
	return pixel.x >= 0 && pixel.x < size.x && pixel.y >= 0 && pixel.y < size.y


func _sample_by_denisty():
	var sampled_points: Array = []
	#temporary
	var terrain_size = Vector2(20.0, 20.0)
	var density_size = densitymap.get_size()
	var texture_density_scale = density_size / terrain_size
	var cell_cords = terrain_inv_transform.xform(Vector3(chunk_position.x, 0, chunk_position.y))
	#temporary
	cell_cords += Vector3(terrain_size.x / 2.0, 0, terrain_size.y / 2.0)
	var local_density = densitymap.duplicate()
	local_density.lock()
	for pos in sampling_array:
		var pos_terrain: Vector2 = (
			pos / stamp_size * chunk_size
			+ Vector2(cell_cords.x, cell_cords.z)
		)
		var tex_coords: Vector2 = (pos_terrain * texture_density_scale).floor()
		if not _is_in_range(tex_coords, density_size):
			continue
		var color = local_density.get_pixelv(tex_coords)
		if _dither_density(1.0 - color.r, pos / dithering_scale):
			sampled_points.append(pos)
	local_density.unlock()
	return sampled_points


func _get_density_texture():
	var it = ImageTexture.new()
	it.create_from_image(densitymap)
	return it


func _generate_subset(_userdata):
	var rng = RandomNumberGenerator.new()
	while _running:
		_semaphore.wait()
		if not _running:
			return
		var sampled_points = _sample_by_denisty()
		self.global_transform.origin = Vector3(chunk_position.x, 0, chunk_position.y)
		rng.seed = int(self.global_transform.origin.length())
		if sampled_points.size() > self.multimesh.instance_count:
			self.multimesh.instance_count = sampled_points.size()
		self.multimesh.visible_instance_count = sampled_points.size()
		for i in range(sampled_points.size()):
			var pos2: Vector2 = sampled_points[i] / (stamp_size / chunk_size)
			var position = Vector3(pos2.x, 0, pos2.y)
			var rand_hash = rng.randf_range(0.0, 1.0)
			var rand_scale3 = (
				Vector3(rand_hash, rand_hash, rand_hash)
				* object_scale_variation
				* object_scale
			)
			var rand_rotation = rand_hash * object_rotation_variation
			var tb = Basis()
			tb = tb.scaled(Vector3(object_scale + rand_scale3))
			tb = tb.rotated(Vector3.UP, rand_rotation)
			var t = Transform(tb)
			t.origin = position
			self.multimesh.set_instance_transform(i, t)

		if sampled_points.size() == 0:
			self.visible = false
			return
		else:
			self.visible = true


func _ready():
	self.visible = false
	self.multimesh = MultiMesh.new()
	self.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	self.multimesh.color_format = MultiMesh.COLOR_NONE
	self.multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	self.multimesh.instance_count = maximum_instance_count
	self.multimesh.visible_instance_count = 0
	self.multimesh.mesh = mesh
	for i in range(self.multimesh.instance_count):
		var t = Transform(Basis(), Vector3(0, 0, 0))
		self.multimesh.set_instance_transform(i, t)
	_thread = Thread.new()
	_semaphore = Semaphore.new()
	_thread.start(self, "_generate_subset")


func generate():
	_semaphore.post()


func _exit_tree():
	_running = false
	_semaphore.post()
	_thread.wait_to_finish()
