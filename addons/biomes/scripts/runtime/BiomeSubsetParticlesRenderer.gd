extends Particles

export (Array) var sampling_array = []
export (bool) var enable_shadows = false
export (bool) var gpu_compute = false
export (Image) var densitymap
export (int) var id = -1
export (Mesh) var mesh = preload("res://assets/meshes/spheremesh.tres")
export (Transform) var terrain_inv_transform
export (Vector2) var chunk_size = Vector2(10, 10)
export (Vector2) var chunk_position = Vector2(0, 0)
export (Vector2) var stamp_size = Vector2(256, 256)
export (float) var dithering_scale = 10.0
export (Vector3) var object_scale = Vector3(1, 1, 1)
export (float) var object_scale_variation = 0.3
export (float) var object_rotation_variation = 3.14*2.0

var _visibility_height_range = 800
var _semaphore: Semaphore
var _thread: Thread
var _running = true

var Array2dToShader = preload("res://addons/biomes/scripts/runtime/Array2DToShader.gd")
var ParticlePlacementShader = preload("res://addons/biomes/shaders/particle_placer.shader")
var ParticlePlacementShaderGPU = preload("res://addons/biomes/shaders/particle_placer_gpu.shader")


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


func setup():
	self.global_transform.origin = Vector3(chunk_position.x, 0, chunk_position.y)
	self.visibility_aabb = AABB(
		Vector3(0, -_visibility_height_range / 2, 0),
		Vector3(chunk_size.x, _visibility_height_range, chunk_size.y)
	)
	if enable_shadows:
		self.cast_shadow = SHADOW_CASTING_SETTING_ON
	else:
		self.cast_shadow = SHADOW_CASTING_SETTING_OFF
	if gpu_compute:
		self.process_material.set_shader_param("u_densitymap", _get_density_texture())
		self.process_material.set_shader_param("u_dithering_scale", dithering_scale)

	self.process_material.set_shader_param("u_stamp_size", stamp_size)
	self.process_material.set_shader_param("u_chunk_size", chunk_size)
	self.process_material.set_shader_param("u_chunk_pos", chunk_position)
	self.process_material.set_shader_param("u_terrain_inv_transform", terrain_inv_transform)
	self.process_material.set_shader_param("u_scale", object_scale)
	self.process_material.set_shader_param("u_scale_variaton", object_scale_variation)
	self.process_material.set_shader_param("u_rotation_variaton", object_rotation_variation)


func _generate_subset(_userdata):
	while _running:
		_semaphore.wait()
		if not _running:
			return
		var sampled_points = sampling_array
		if not gpu_compute:
			sampled_points = _sample_by_denisty()
		if sampled_points.size() == 0:
			self.visible = false
			return
		else:
			self.visible = true
		setup()
		var tex: ImageTexture = Array2dToShader.generate(sampled_points)
		self.process_material.set_shader_param("u_stamp_array", tex)
		self.amount = sampled_points.size()



func _ready():
	self.visible = true
	self.explosiveness = 1.0
	self.draw_order = DRAW_ORDER_VIEW_DEPTH
	self.draw_pass_1 = mesh
	self.process_material = ShaderMaterial.new()
	if gpu_compute:
		self.process_material.shader = ParticlePlacementShaderGPU
	else:
		self.process_material.shader = ParticlePlacementShader
	self.amount = 1
	_thread = Thread.new()
	_semaphore = Semaphore.new()
	_thread.start(self, "_generate_subset")


func generate():
	_semaphore.post()


func _exit_tree():
	_running = false
	_semaphore.post()
	_thread.wait_to_finish()
