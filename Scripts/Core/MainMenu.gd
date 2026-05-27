extends Node2D

@onready var background = $Background
@onready var train_body = $TrainLayer/TrainBody
@onready var smoke = $TrainLayer/TrainBody/Steam
@onready var title_label = $UI/CenterContainer/VBoxContainer/TitleLabel
@onready var subtitle_label = $UI/CenterContainer/VBoxContainer/SubtitleLabel
@onready var start_button = $UI/CenterContainer/VBoxContainer/StartButton

var train_speed = 75.0

func _ready() -> void:
	
	#start_button.theme = load("res://your_theme_file.tres")
	var font = load("res://Assets/Fonts/m5x7.ttf")
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_font_override("font", font)
	subtitle_label.add_theme_font_size_override("font_size", 8)
	start_button.add_theme_font_override("font", font)
	start_button.add_theme_font_size_override("font_size", 8)
	start_button.add_theme_stylebox_override("hover", null)


	background.color = Color(0.05, 0.05, 0.1)
	background.size = get_viewport_rect().size
	background.position = Vector2.ZERO

	train_body.color = Color(0.15, 0.15, 0.15)
	train_body.size = Vector2(100, 15)
	train_body.position = Vector2(-100, 150)
	smoke.emitting = true

	title_label.text = "ROGUELAW"
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	subtitle_label.text = "No mercy. No pardon."
	subtitle_label.add_theme_font_size_override("font_size", 8)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	start_button.text = "NEW OUTLAW"
	start_button.pressed.connect(_on_start_pressed)

func _process(delta: float) -> void:
	train_body.position.x += train_speed * delta
	if train_body.position.x > 320:
		train_body.position.x = -100

func _on_start_pressed() -> void:
	GameState.start_game()
