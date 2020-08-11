extends Node

signal stamp_updated(image)

export (Vector2) var stamp_size = Vector2(256, 256)
export (float) var new_points_retries = 10
export (bool) var fill_pass_enabled = false

var _biome_placement_nodes: Array = []
var _grid: Array = []
var _min_max_distance: Vector2 = Vector2()
var _sample_points: Array = []
var _semaphore: Semaphore
var _stampImage: Image = null
var _stamp_array_size = Vector2()
var _sqrt2 = sqrt(2)
var _thread: Thread
var _running: bool = true

var BiomePlacementNode = preload("res://addons/wojtekpil.biomes/scripts/BiomePlacementNode.gd")
var StampPoint = preload("res://addons/wojtekpil.biomes/scripts/StampPoint.gd")


func grid_generate(width: int, height: int, min_dist: float):
	var cell_size = min_dist / _sqrt2
	var cols = ceil(width / cell_size)
	var rows = ceil(height / cell_size)
	for y in range(cols):
		_grid.append([])
		_grid[y].resize(rows)

		for x in range(rows):
			_grid[y][x] = []
	_stamp_array_size = Vector2(cols, rows)


func position_to_grid(point: Vector2, cell_size: float):
	var grid_x = int(point.x / cell_size)
	var grid_y = int(point.y / cell_size)
	return Vector2(grid_x, grid_y)


func mix_pop_list(list: Array):
	if randf() < 0.5:
		return list.pop_back()
	return list.pop_front()


func generate_random_point_around(point: Object, min_dist: float):
	var r1 = randf()
	var r2 = randf()
	var radius = min_dist * (r1 + 1.0)
	var stamp_point = StampPoint.new()
	#random angle
	var angle = 2.0 * PI * r2
	#the new point is generated around the point (x, y)
	var new_x = point.position.x + radius * cos(angle)
	var new_y = point.position.y + radius * sin(angle)
	stamp_point.position = Vector2(new_x, new_y)
	stamp_point.radius = min_dist / 2.0
	return stamp_point


func in_stamp_size(point: Vector2):
	return point.x > 0 && point.x < stamp_size.x && point.y > 0 && point.y < stamp_size.y


func draw_circle(point: Vector2, radius: int, image: Image, color: Color, width: float = 1.5):
	point = Vector2(int(point.x), int(point.y))
	for x in range(point.x - radius, point.x + radius):
		for y in range(point.y - radius, point.y + radius):
			var point_circle = Vector2(x, y)
			if ! in_stamp_size(point_circle):
				continue
			if (
				point_circle.distance_to(point) < radius
				&& point_circle.distance_to(point) > radius - width
			):
				image.set_pixel(int(point_circle.x), int(point_circle.y), color)


func generate_image(width: int, height: int, min_dist: float):
	var cell_size = min_dist / _sqrt2
	var cols = ceil(width / cell_size)
	var rows = ceil(height / cell_size)
	var img = Image.new()
	var color = Color(1, 0, 0)

	img.create(width, height, false, Image.FORMAT_RGBA8)
	img.lock()

	for y in range(cols):
		for x in range(rows):
			if _grid[y][x] == null:
				continue
			for cell_point in _grid[y][x]:
				var point_pos = cell_point.position
				img.set_pixel(int(point_pos.x), int(point_pos.y), color)
				#print(cell_point.color)
				draw_circle(point_pos, int(cell_point.radius), img, cell_point.color)
	img.unlock()
	_stampImage = img
	return img


func square_around_point(grid, grid_point, neighbour_distance):
	var found_points = []

	var min_iter_x = max(0, grid_point.x - neighbour_distance)
	var max_iter_x = min(_stamp_array_size.x, grid_point.x + neighbour_distance + 1)
	var min_iter_y = max(0, grid_point.y - neighbour_distance)
	var max_iter_y = min(_stamp_array_size.y, grid_point.y + neighbour_distance + 1)

	for x in range(min_iter_x, max_iter_x):
		for y in range(min_iter_y, max_iter_y):
			if grid[x][y] != null:
				for point in grid[x][y]:
					found_points.append(point)
	return found_points


func in_neighbourhood(grid, point, mindist, cell_size, fill_pass = false):
	var real_grid = int(mindist / _min_max_distance.x)

	var significant_grids = 2
	if fill_pass == true:
		significant_grids = max(ceil(_min_max_distance.y / mindist) * 2, 2)
	var grid_point = position_to_grid(point, cell_size)
	var cells_around_point = square_around_point(grid, grid_point, real_grid * significant_grids)
	for cell in cells_around_point:
		if cell == null:
			continue
		if cell.position.distance_to(point) < cell.radius + mindist / 2.0:
			return true
	return false


func generate_poisson(
	id: int,
	width: int,
	height: int,
	min_dist: float,
	density: float,
	color: Color,
	new_points_count: int,
	last_pass = null,
	fill_pass = false
):
	var cell_size = _min_max_distance.x / _sqrt2

	var process_list = []
	var sample_points = []
	var current_pass_sample_points = []

	if last_pass == null:
		var first_point = StampPoint.new()
		first_point.position = Vector2(rand_range(0, width), rand_range(0, height))
		first_point.radius = min_dist / 2.0
		first_point.color = color
		first_point.id = id

		process_list.append(first_point)
		sample_points.append(first_point)

		var fp_pos = position_to_grid(first_point.position, cell_size)
		_grid[fp_pos.x][fp_pos.y].append(first_point)
	else:
		process_list = last_pass.duplicate(true)
		sample_points = last_pass.duplicate(true)

	while ! process_list.empty():
		var point = mix_pop_list(process_list)
		for _i in range(new_points_count):
			var new_point = generate_random_point_around(point, min_dist)
			new_point.color = color
			new_point.id = id

			if (
				in_stamp_size(new_point.position)
				&& ! in_neighbourhood(_grid, new_point.position, min_dist, cell_size, fill_pass)
			):
				var gp_pos = position_to_grid(new_point.position, cell_size)
				process_list.push_back(new_point)
				sample_points.push_back(new_point)
				current_pass_sample_points.push_back(new_point)
				_grid[gp_pos.x][gp_pos.y].append(new_point)

	#do a density pass
	var removal_count = current_pass_sample_points.size() * (1.0 - density)
	while removal_count > 0:
		var rand_index = randi() % current_pass_sample_points.size()
		var gp_pos = position_to_grid(current_pass_sample_points[rand_index].position, cell_size)
		var sample_index = sample_points.find(current_pass_sample_points[rand_index])
		var sample_grid_index = _grid[gp_pos.x][gp_pos.y].find(
			current_pass_sample_points[rand_index]
		)
		if sample_grid_index >= 0:
			_grid[gp_pos.x][gp_pos.y].remove(sample_grid_index)
		current_pass_sample_points.remove(rand_index)
		if sample_index >= 0:
			sample_points.remove(sample_index)
		removal_count -= 1

	return sample_points


func generate_stampling():
	grid_generate(stamp_size.x, stamp_size.y, _min_max_distance.x)
	var sample_points = null
	var acumulated_density = 1.0
	var scalar = 0
	for i in range(0, _biome_placement_nodes.size()):
		scalar += _biome_placement_nodes[i].density

	for i in range(0, _biome_placement_nodes.size()):
		var bpn = _biome_placement_nodes[i]
		var density = bpn.density / scalar
		sample_points = generate_poisson(
			bpn.id,
			stamp_size.x,
			stamp_size.y,
			bpn.footprint,
			density / max(acumulated_density, 0.001),
			bpn.color,
			new_points_retries,
			sample_points
		)
		acumulated_density -= density
		print("Generating group id: ", bpn.id)
	print("First pass completed")
	
	if fill_pass_enabled:
		for i in range(_biome_placement_nodes.size() - 2, -1, -1):
			var bpn = _biome_placement_nodes[i]
			sample_points = generate_poisson(
				bpn.id,
				stamp_size.x,
				stamp_size.y,
				bpn.footprint,
				1.0,
				bpn.color * 0.7,
				new_points_retries,
				sample_points,
				true
			)
			print("Generating group id: ", bpn.id)
		print("Second pass completed")

	_sample_points = sample_points.duplicate()

	var image = generate_image(stamp_size.x, stamp_size.y, _min_max_distance.x)
	emit_signal("stamp_updated", image)


func _background_updater(_userdata):
	while _running:
		_semaphore.wait()
		if not _running:
			return
		if _biome_placement_nodes.empty():
			continue
		generate_stampling()
		OS.delay_msec(1000)


func setup_biome_placement_nodes(nodes: Array):
	_biome_placement_nodes = nodes
	prepare_biome()
	_semaphore.post()


func prepare_biome():
	_biome_placement_nodes.sort_custom(BiomePlacementNode, "compare_by_footprint")
	_min_max_distance.x = _biome_placement_nodes[0].footprint
	_min_max_distance.y = _biome_placement_nodes[-1].footprint
	print(_biome_placement_nodes)
	print(_min_max_distance)


func query_points_by_id(id: int):
	var id_arr: Array = []
	for x in _sample_points:
		if x.id != id:
			continue
		id_arr.append(x.position)
	return id_arr


func generate_stamp_data():
	var stamp: Dictionary = {}
	for bi in _biome_placement_nodes:
		var id = bi.id
		stamp[id] = query_points_by_id(id)
	return stamp


func _init():
	_thread = Thread.new()
	_semaphore = Semaphore.new()
	_thread.start(self, "_background_updater")


func _exit_tree():
	_running = false
	_semaphore.post()
	_thread.wait_to_finish()
