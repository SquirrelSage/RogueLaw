extends Node2D

@onready var background = $Background
@onready var train_body = $TrainLayer/TrainBody
@onready var title_label = $UI/TitleLabel
@onready var subtitle_label = $UI/SubtitleLabel
@onready var start_button = $UI/StartButton
@onready var smoke = $TrainLayer/TrainBody/Steam

var train_speed = 300.0

func _ready() -> void:
	# Background — dark night sky
	background.color = Color(0.05, 0.05, 0.1)
	background.size = Vector2(1280, 720)
	background.position = Vector2(0, 0)
	
	# Train — starts off screen left
	train_body.color = Color(0.15, 0.15, 0.15)
	train_body.size = Vector2(400, 60)
	train_body.position = Vector2(-400, 300)
	smoke.emitting = true
	
	# Title
	title_label.text = "ROGUELAW"
	title_label.position = Vector2(400, 150)
	title_label.add_theme_font_size_override("font_size", 64)
	
	# Subtitle
	subtitle_label.text = "No mercy. No pardon."
	subtitle_label.position = Vector2(490, 230)
	subtitle_label.add_theme_font_size_override("font_size", 18)
	
	# Start button
	start_button.text = "NEW OUTLAW"
	start_button.position = Vector2(515, 400)
	start_button.pressed.connect(_on_start_pressed)

func _process(delta: float) -> void:
	# Train moves left to right
	train_body.position.x += train_speed * delta
	
	# Loop train back when it goes off screen
	if train_body.position.x > 1280:
		train_body.position.x = -400

func _on_start_pressed() -> void:
	GameState.start_game()
