extends CanvasLayer
class_name HUD

@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaBar
@onready var fear_bar: ProgressBar = $MarginContainer/VBoxContainer/FearBar
@onready var message_label: Label = $CenterContainer/MessageLabel

var player: Player = null

func _ready():
	# Find player in scene
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if stamina_bar:
		stamina_bar.max_value = 100
		stamina_bar.value = 100

	if fear_bar:
		fear_bar.max_value = 100
		fear_bar.value = 0

	if message_label:
		message_label.text = ""

func _process(_delta):
	if player:
		if stamina_bar:
			stamina_bar.value = player.get_stamina_percent() * 100

		if fear_bar:
			fear_bar.value = player.get_fear_percent() * 100

func show_message(text: String, duration: float = 3.0):
	if message_label:
		message_label.text = text
		await get_tree().create_timer(duration).timeout
		message_label.text = ""
