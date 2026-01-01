extends CharacterBody3D
class_name Player

# Movement parameters
@export var normal_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@export var head_bob_frequency: float = 2.0
@export var head_bob_amplitude: float = 0.08

# Stamina system
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 25.0
@export var stamina_regen_rate: float = 15.0
var current_stamina: float = 100.0
var is_exhausted: bool = false

# Fear mechanics
var fear_level: float = 0.0
var breathing_intensity: float = 0.0

# References
@onready var camera: Camera3D = $Camera3D
@onready var head_bob_timer: float = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_stamina = max_stamina

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

	# Toggle mouse capture (ESC key)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Handle sprinting and stamina
	var is_sprinting = Input.is_action_pressed("sprint") and input_dir.y < 0 and not is_exhausted
	var current_speed = sprint_speed if is_sprinting else normal_speed

	# Update stamina
	if is_sprinting and direction.length() > 0:
		current_stamina -= stamina_drain_rate * delta
		if current_stamina <= 0:
			current_stamina = 0
			is_exhausted = true
	else:
		current_stamina += stamina_regen_rate * delta
		if current_stamina >= max_stamina:
			current_stamina = max_stamina
		if current_stamina > 30:
			is_exhausted = false

	# Movement
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		# Head bob effect
		if is_on_floor():
			head_bob_timer += delta * head_bob_frequency * (2.0 if is_sprinting else 1.0)
			camera.position.y = 0.6 + sin(head_bob_timer) * head_bob_amplitude
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		# Reset head bob
		camera.position.y = move_toward(camera.position.y, 0.6, delta * 2.0)

	move_and_slide()

	# Update breathing based on stamina
	breathing_intensity = 1.0 - (current_stamina / max_stamina)

func increase_fear(amount: float):
	fear_level = clamp(fear_level + amount, 0.0, 100.0)

func decrease_fear(amount: float):
	fear_level = clamp(fear_level - amount, 0.0, 100.0)

func get_stamina_percent() -> float:
	return current_stamina / max_stamina

func get_fear_percent() -> float:
	return fear_level / 100.0
