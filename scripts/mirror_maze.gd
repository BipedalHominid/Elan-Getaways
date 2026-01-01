extends Node3D
class_name MirrorMaze

# Maze configuration
@export var maze_width: int = 20
@export var maze_height: int = 20
@export var cell_size: float = 4.0
@export var wall_height: float = 4.0

# Materials
@export var mirror_material: Material
@export var floor_material: Material

# Prefabs
@export var jumpscare_trigger_scene: PackedScene

var maze_grid: Array = []
var player_spawn: Vector3
var killy_spawn: Vector3

func _ready():
	generate_maze()
	create_maze_geometry()
	place_jump_scares()
	setup_atmosphere()

func generate_maze():
	# Initialize grid
	maze_grid = []
	for y in range(maze_height):
		var row = []
		for x in range(maze_width):
			row.append(1)  # 1 = wall, 0 = path
		maze_grid.append(row)

	# Generate using recursive backtracker algorithm
	var stack = []
	var start_x = 1
	var start_y = 1
	maze_grid[start_y][start_x] = 0
	stack.append(Vector2i(start_x, start_y))

	var directions = [Vector2i(0, -2), Vector2i(2, 0), Vector2i(0, 2), Vector2i(-2, 0)]

	while stack.size() > 0:
		var current = stack[-1]
		var unvisited = []

		for dir in directions:
			var next = current + dir
			if next.x > 0 and next.x < maze_width - 1 and next.y > 0 and next.y < maze_height - 1:
				if maze_grid[next.y][next.x] == 1:
					unvisited.append(dir)

		if unvisited.size() > 0:
			var chosen = unvisited[randi() % unvisited.size()]
			var next_cell = current + chosen
			var between = current + chosen / 2

			maze_grid[next_cell.y][next_cell.x] = 0
			maze_grid[between.y][between.x] = 0
			stack.append(next_cell)
		else:
			stack.pop_back()

	# Set spawn points
	player_spawn = Vector3(cell_size * 1.5, 1, cell_size * 1.5)
	killy_spawn = Vector3(cell_size * (maze_width - 2.5), 0, cell_size * (maze_height - 2.5))

func create_maze_geometry():
	# Create floor
	var floor = MeshInstance3D.new()
	var floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(maze_width * cell_size, 0.2, maze_height * cell_size)
	floor.mesh = floor_mesh
	floor.position = Vector3(maze_width * cell_size / 2, -0.1, maze_height * cell_size / 2)

	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.1, 0.1, 0.1)
	floor_mat.metallic = 0.3
	floor_mat.roughness = 0.8
	floor.material_override = floor_mat
	add_child(floor)

	# Create collision for floor
	var floor_body = StaticBody3D.new()
	var floor_shape = CollisionShape3D.new()
	var floor_box = BoxShape3D.new()
	floor_box.size = Vector3(maze_width * cell_size, 0.2, maze_height * cell_size)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	floor_body.position = floor.position
	add_child(floor_body)

	# Create walls
	for y in range(maze_height):
		for x in range(maze_width):
			if maze_grid[y][x] == 1:
				create_wall(x, y)

func create_wall(x: int, y: int):
	var wall = MeshInstance3D.new()
	var wall_mesh = BoxMesh.new()
	wall_mesh.size = Vector3(cell_size, wall_height, cell_size)
	wall.mesh = wall_mesh

	# Mirror material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.8, 0.9)
	mat.metallic = 1.0
	mat.roughness = 0.1
	mat.rim_enabled = true
	mat.rim = 0.3
	mat.rim_tint = 0.5
	wall.material_override = mat

	wall.position = Vector3(x * cell_size + cell_size/2, wall_height/2, y * cell_size + cell_size/2)
	add_child(wall)

	# Add collision
	var body = StaticBody3D.new()
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(cell_size, wall_height, cell_size)
	shape.shape = box
	body.add_child(shape)
	body.position = wall.position
	add_child(body)

func place_jump_scares():
	# Place 8-12 jump scare triggers throughout the maze
	var scare_count = randi_range(8, 12)
	var placed = 0

	while placed < scare_count:
		var x = randi_range(2, maze_width - 3)
		var y = randi_range(2, maze_height - 3)

		if maze_grid[y][x] == 0:  # Only place on paths
			var trigger = create_jumpscare_trigger()
			trigger.position = Vector3(x * cell_size + cell_size/2, 1.5, y * cell_size + cell_size/2)
			add_child(trigger)
			placed += 1

func create_jumpscare_trigger() -> Area3D:
	var trigger = Area3D.new()
	trigger.add_to_group("jumpscare")

	# Add script
	var script_path = "res://scripts/jumpscare_trigger.gd"
	trigger.set_script(load(script_path))

	# Add collision shape
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(3, 3, 3)
	shape.shape = box
	trigger.add_child(shape)

	# Randomize scare type
	var scare_types = ["killy_popup", "shadow_figure", "whisper", "mirror_reflection", "breathing"]
	trigger.jumpscare_type = scare_types[randi() % scare_types.size()]
	trigger.fear_increase = randf_range(20.0, 50.0)

	return trigger

func setup_atmosphere():
	# Add fog
	var env = get_node_or_null("/root/Main/WorldEnvironment")
	if env and env.environment:
		env.environment.fog_enabled = true
		env.environment.fog_density = 0.05
		env.environment.fog_light_color = Color(0.2, 0.2, 0.3)

	# Add flickering lights
	for i in range(5):
		var light = OmniLight3D.new()
		light.light_energy = randf_range(1.0, 2.5)
		light.light_color = Color(1.0, 0.9, 0.7)
		light.omni_range = 15.0

		var x = randi_range(2, maze_width - 3)
		var y = randi_range(2, maze_height - 3)
		light.position = Vector3(x * cell_size, 3.0, y * cell_size)
		add_child(light)

		# Add flickering script
		var flicker = FlickeringLight.new()
		light.add_child(flicker)

func get_player_spawn() -> Vector3:
	return player_spawn

func get_killy_spawn() -> Vector3:
	return killy_spawn

# Flickering light class
class FlickeringLight extends Node:
	var flicker_timer: float = 0.0
	var flicker_speed: float = randf_range(0.1, 0.3)

	func _process(delta):
		flicker_timer += delta
		if flicker_timer > flicker_speed:
			var light = get_parent() as OmniLight3D
			if light:
				light.light_energy = randf_range(0.5, 2.5)
				if randf() < 0.1:  # 10% chance to go dark
					light.light_energy = 0.1
			flicker_timer = 0.0
			flicker_speed = randf_range(0.05, 0.4)
