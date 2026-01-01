extends Area3D
class_name JumpscareTrigger

# Jumpscare settings
@export var jumpscare_type: String = "killy_popup"
@export var one_time_only: bool = true
@export var jumpscare_delay: float = 0.0
@export var fear_increase: float = 50.0

# Audio and visual
@export var jumpscare_sound: AudioStream
@export var jumpscare_texture: Texture2D

var has_triggered: bool = false
var is_triggering: bool = false

signal jumpscare_triggered(type: String)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if has_triggered and one_time_only:
		return

	if body.is_in_group("player") and not is_triggering:
		trigger_jumpscare(body)

func trigger_jumpscare(player):
	is_triggering = true
	has_triggered = true

	if jumpscare_delay > 0:
		await get_tree().create_timer(jumpscare_delay).timeout

	# Emit signal
	jumpscare_triggered.emit(jumpscare_type)

	# Increase player fear
	if player.has_method("increase_fear"):
		player.increase_fear(fear_increase)

	# Play sound
	if jumpscare_sound:
		play_jumpscare_sound()

	# Show visual
	if jumpscare_texture:
		show_jumpscare_visual()

	await get_tree().create_timer(1.0).timeout
	is_triggering = false

func play_jumpscare_sound():
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = jumpscare_sound
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()

func show_jumpscare_visual():
	# This would create a full-screen flash of the jumpscare image
	print("JUMPSCARE VISUAL: ", jumpscare_type)
	# TODO: Implement visual popup in UI layer
