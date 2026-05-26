extends Node2D

@onready var name_label = $Screen/VBox/NameLabel
@onready var cause_label = $Screen/VBox/CauseLabel
@onready var stats_label = $Screen/VBox/StatsLabel
@onready var wanted_label = $Screen/VBox/WantedLabel
@onready var restart_btn = $Screen/VBox/RestartButton

func _ready() -> void:
	wanted_label.text = "-- WANTED DEAD --"
	name_label.text = RunData.player_name
	cause_label.text = RunData.death_cause
	stats_label.text = "Heat: %d | Money: $%d | Crew: %d" % [
		RunData.global_heat,
		RunData.money,
		RunData.crew.size()
	]
	restart_btn.text = "New Outlaw"
	restart_btn.pressed.connect(_on_restart)
	restart_btn.release_focus()

func _on_restart() -> void:
	GameState.start_game()
