extends Particles

export (int) var id = -1
export (Array) var sampling_array = []
export (Vector2) var chunk_size = Vector2(10, 10)
export (Vector2) var chunk_position = Vector2(0, 0)
export (Vector2) var stamp_size = Vector2(512, 512)
export (Mesh) var mesh = preload("res://assets/meshes/spheremesh.tres")
export (bool) var enable_shadows = false
var _visibility_height_range = 800

var Array2dToShader = preload("res://scripts/Array2DToShader.gd")
var ParticlePlacementShader = preload("res://shaders/particle_placer.shader")


func setup():
	self.global_transform.origin = Vector3(chunk_position.x, 0, chunk_position.y)
	self.amount = 1
	self.explosiveness = 1.0
	self.draw_order = DRAW_ORDER_VIEW_DEPTH
	self.draw_pass_1 = mesh
	self.visibility_aabb = AABB(
		Vector3(0, -_visibility_height_range / 2, 0),
		Vector3(chunk_size.x, _visibility_height_range, chunk_size.y)
	)
	if enable_shadows:
		self.cast_shadow = SHADOW_CASTING_SETTING_ON
	self.process_material = ShaderMaterial.new()
	self.process_material.shader = ParticlePlacementShader
	self.process_material.set_shader_param("stamp_size", stamp_size)
	self.process_material.set_shader_param("chunk_size", chunk_size)
	self.process_material.set_shader_param("chunk_pos", chunk_position)


func generate():
	setup()
	var tex: ImageTexture = Array2dToShader.generate(sampling_array)
	self.process_material.set_shader_param("stamp_array", tex)
	self.amount = sampling_array.size()
