extends CharacterBody3D
class_name KillyAI

enum State {
	IDLE,
	PATROL,
	CHASE,
	JUMPSCARE,
	LOST_PLAYER
}

# AI parameters
@export var patrol_speed: float = 2.0
@export var chase_speed: float = 6.0
@export var detection_range: float = 15.0
@export var lose_range: float = 25.0
@export var attack_range: float = 2.0

# References
@export var player: Node3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var current_state: State = State.PATROL
var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var time_since_saw_player: float = 0.0
var max_search_time: float = 10.0

func _ready():
	# Set up navigation
	if navigation_agent:
		navigation_agent.path_desired_distance = 0.5
		navigation_agent.target_desired_distance = 0.5

	# Generate random patrol points if none exist
	if patrol_points.is_empty():
		generate_patrol_points()

func _physics_process(delta):
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase(delta)
		State.JUMPSCARE:
			_state_jumpscare(delta)
		State.LOST_PLAYER:
			_state_lost_player(delta)

	move_and_slide()

func _state_idle(delta):
	velocity = Vector3.ZERO
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < detection_range:
			change_state(State.CHASE)

func _state_patrol(delta):
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < detection_range and can_see_player():
			change_state(State.CHASE)
			return

	# Navigate to patrol point
	if patrol_points.is_empty():
		return

	var target = patrol_points[current_patrol_index]
	navigation_agent.target_position = target

	if navigation_agent.is_navigation_finished():
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	else:
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		velocity = direction * patrol_speed
		look_at(global_position + direction, Vector3.UP)

func _state_chase(delta):
	if not player:
		change_state(State.PATROL)
		return

	var distance = global_position.distance_to(player.global_position)

	# Check if caught player
	if distance < attack_range:
		change_state(State.JUMPSCARE)
		return

	# Check if lost player
	if distance > lose_range or not can_see_player():
		time_since_saw_player += delta
		if time_since_saw_player > 2.0:
			change_state(State.LOST_PLAYER)
			return
	else:
		time_since_saw_player = 0.0

	# Chase player
	navigation_agent.target_position = player.global_position
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	velocity = direction * chase_speed
	look_at(global_position + direction, Vector3.UP)

	# Increase player fear
	if player.has_method("increase_fear"):
		player.increase_fear(20.0 * delta)

func _state_jumpscare(delta):
	velocity = Vector3.ZERO
	# Trigger jumpscare event
	# TODO: Play jumpscare animation and sound
	print("JUMPSCARE!")
	await get_tree().create_timer(3.0).timeout
	reset_game()

func _state_lost_player(delta):
	time_since_saw_player += delta

	# Search around last known position
	if navigation_agent.is_navigation_finished():
		# If search time exceeded, return to patrol
		if time_since_saw_player > max_search_time:
			change_state(State.PATROL)
	else:
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		velocity = direction * patrol_speed
		look_at(global_position + direction, Vector3.UP)

	# Check if spotted player again
	if player and can_see_player():
		var distance = global_position.distance_to(player.global_position)
		if distance < detection_range:
			change_state(State.CHASE)

func change_state(new_state: State):
	current_state = new_state
	time_since_saw_player = 0.0

	match new_state:
		State.PATROL:
			print("Killy: Patrolling...")
		State.CHASE:
			print("Killy: CHASING!")
		State.JUMPSCARE:
			print("Killy: GOTCHA!")
		State.LOST_PLAYER:
			print("Killy: Where did they go?")

func can_see_player() -> bool:
	if not player:
		return false

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1, 0),
		player.global_position + Vector3(0, 1, 0)
	)
	var result = space_state.intersect_ray(query)

	if result and result.collider == player:
		return true
	return false

func generate_patrol_points():
	# Generate 4 patrol points in a square pattern
	var center = global_position
	var radius = 10.0
	patrol_points = [
		center + Vector3(radius, 0, radius),
		center + Vector3(radius, 0, -radius),
		center + Vector3(-radius, 0, -radius),
		center + Vector3(-radius, 0, radius)
	]

func reset_game():
	# Reset player and Killy positions
	if player and player.has_method("reset_position"):
		player.reset_position()
	global_position = Vector3.ZERO
	change_state(State.PATROL)
