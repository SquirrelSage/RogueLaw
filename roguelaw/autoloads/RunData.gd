extends Node

#Region Data
var towns: Array = []
var connections: Array = []
var region_generated: bool = false

# Player
var player_name: String = ""
var money: int = 20
var health: int = 100
var reputation: int = 0

# Horse
var horse_sprite: String = "res://Assets/Sprites/horse_mule.png"
var horse_name: String = ""
var horse_tier: int = 0  # 0 = mule, 1 = quarterhorse, 2 = thoroughbred etc
var horse_stamina: float = 100.0
var horse_alive: bool = true

# Heat
var global_heat: int = 0
var regional_heat: Dictionary = {}  # town_id: heat_value
var bounty_hunter_active: bool = false
var bounty_hunter_proximity: int = 0

# Crew
var crew: Array = []
var max_crew: int = 2

# Inventory
var guns: Array = []
var supplies: Dictionary = {
	"ammo": 12,
	"dynamite": 0
}

# Run state
var current_region = null
var current_town = null
var current_job = null
var run_active: bool = false
var days_survived: int = 0
var death_cause: String = ""

func start_new_run(name: String) -> void:
	player_name = name
	money = 50
	health = 100
	reputation = 0
	horse_tier = 0
	horse_stamina = 100
	horse_alive = true
	global_heat = 0
	regional_heat = {}
	bounty_hunter_active = false
	bounty_hunter_proximity = 0
	crew = []
	guns = []
	towns = []
	connections = []
	region_generated = false
	supplies = {"ammo": 12, "dynamite": 0}
	days_survived = 0
	run_active = true
	EventBus.run_started.emit()

func end_run(cause: String) -> void:
	run_active = false
	death_cause = cause
	EventBus.run_ended.emit(cause)

func add_money(amount: int) -> void:
	money += amount
	EventBus.money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		EventBus.money_changed.emit(money)
		return true
	return false

func add_heat(amount: int) -> void:
	global_heat = clamp(global_heat + amount, 0, 100)
	EventBus.heat_changed.emit(global_heat)
	if global_heat >= 75 and not bounty_hunter_active:
		bounty_hunter_active = true
		EventBus.bounty_hunter_spawned.emit()

func take_damage(amount: int) -> void:
	health = clamp(health - amount, 0, 100)
	EventBus.health_changed.emit(health)
