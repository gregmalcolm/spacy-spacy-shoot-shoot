extends Node2D

@export var tile_size := Vector2(200, 200)

var particles_matrix

func _ready():
	_setupParticles()


func _process(_delta):
	_align_particles_on_grid()
	


func _on_rebuild_timer_timeout(node):
	print("_on_rebuild_timer_timeout index: {index} x: {x} y: {y}".format({ 
		"index": node.index, 
		"x": node.x_index, 
		"y": node.y_index,
	}))
	node.speed_scale = 1


func _emptyParticlesMatrix():
	return [[null, null], [null, null]]


func _buildParticlesNode(index = 0, x=0, y=0):
	var mid_tile_size = tile_size * 0.5
	
	var process_material = ParticleProcessMaterial.new()
	process_material.particle_flag_disable_z = true
	process_material.emission_shape = ParticleProcessMaterial.EmissionShape.EMISSION_SHAPE_BOX 
	process_material.emission_shape_offset = Vector3(mid_tile_size.x, mid_tile_size.y, 0)
	process_material.emission_box_extents = Vector3(mid_tile_size.x, mid_tile_size.y, 0)
	process_material.gravity = Vector3.ZERO
	process_material.scale_min = 0.01
	process_material.scale_max = 0.03
	process_material.hue_variation_max = 0.05
	
	var particles = StarfieldParticles.new()
	particles.amount = 100 
	particles.lifetime = 500
	particles.preprocess = 500
	particles.texture = preload("res://addons/kenney_particle-pack/PNG (Transparent)/star_05.png")
	particles.process_material = process_material
	particles.visibility_rect = Rect2(
		Vector2.ZERO,
		tile_size * 1.2,
	)
	particles.position = Vector2.ZERO
	particles.visibility_rect_color = Color.from_hsv(0.2 + (index * 0.2), 0.7, .6, 0.05)
	
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(_on_rebuild_timer_timeout.bind(particles))
	particles.timer = timer
	
	particles.index = index
	particles.x_index = x
	particles.y_index = y
	return particles


func _setupParticles():
	particles_matrix = _emptyParticlesMatrix()
	
	var index = 0
	for y in range(0,2):
		for x in range(0,2):
			particles_matrix[y][x] = _buildParticlesNode(index, x, y)
			index += 1

	particles_matrix[0][1].position.x += tile_size.x
	particles_matrix[0][1].grid_offset.x = tile_size.x
	
	particles_matrix[1][0].position.y += tile_size.y
	particles_matrix[1][0].grid_offset.y = tile_size.y
	
	particles_matrix[1][1].position.x += tile_size.x
	particles_matrix[1][1].position.y += tile_size.y
	particles_matrix[1][1].grid_offset.x = tile_size.x
	particles_matrix[1][1].grid_offset.y = tile_size.y

	for y in range(0,2):
		for x in range(0,2):
			var particles = particles_matrix[y][x]
			particles.position = _grid_alignment(particles.grid_offset)
			add_child(particles)
			add_child(particles.timer)

	
	
func _align_particles_on_grid():
	for y in range(0,2):
		for x in range(0,2):
			_align_paricles_node(particles_matrix[y][x])


func _align_paricles_node(node):
	var old_position = node.position
	node.position = _grid_alignment(node.grid_offset)
	if old_position != node.position:
		_fast_rebuild_particles_node(node)


func _grid_alignment(grid_offset):
	var camera = get_viewport().get_camera_2d()
	var camera_position = camera.get_screen_center_position()

	var pos = Vector2.ZERO
	pos.x = _align_paricles_node_on_axis(
		camera_position.x, 
		tile_size.x,
		grid_offset.x,
	)
	pos.y = _align_paricles_node_on_axis(
		camera_position.y, 
		tile_size.y,
		grid_offset.y,
	)
	return pos

func _align_paricles_node_on_axis(camera_position, tile_len, _grid_offset):
	var snap_offset = tile_len + _grid_offset
	return floor(camera_position/snap_offset) * snap_offset
	

func _fast_rebuild_particles_node(node):
	node.speed_scale = 64
	node.timer.start()

