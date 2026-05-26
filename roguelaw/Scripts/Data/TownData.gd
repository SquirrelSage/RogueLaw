class_name TownData
extends Resource

@export var town_name: String = ""
@export var size: int = 1  # 1 = small, 2 = medium, 3 = large
@export var has_sheriff: bool = false
@export var regional_heat: int = 0
@export var position: Vector2 = Vector2.ZERO

# Buildings present in this town
@export var buildings: Array[String] = []

# Building pool by size
const ALWAYS = ["saloon"]
const COMMON = ["general_store", "stable"]
const UNCOMMON = ["bank", "train_station"]
const RARE = ["gunsmith", "doctor"]

var bank_job = null
var bank_completed: bool = false
var train_job = null
var train_completed: bool = false
var recruit = null
var rumor: String = ""

func generate(pos: Vector2) -> void:
	position = pos
	town_name = _generate_town_name()
	has_sheriff = randf() > 0.4  # 60% chance of sheriff
	buildings = []
	
	# Always present
	buildings.append_array(ALWAYS)
	
	# Common — high chance
	for b in COMMON:
		if randf() > 0.3:
			buildings.append(b)
	
	# Uncommon — medium chance
	for b in UNCOMMON:
		if randf() > 0.6:
			buildings.append(b)
	
	# Rare — low chance
	for b in RARE:
		if randf() > 0.8:
			buildings.append(b)

func _generate_town_name() -> String:
	var prefixes = ["Red", "Dry", "Dusty", "Dead", "Iron", "Black", "Silver", "Lost"]
	var suffixes = ["Creek", "Gulch", "Ridge", "Flats", "Pass", "Fork", "Bluff", "Mesa"]
	return prefixes.pick_random() + " " + suffixes.pick_random()
