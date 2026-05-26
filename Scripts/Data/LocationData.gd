class_name LocationData
extends Resource

enum Type { TOWN, CAMP, CROSSROADS, EXIT }

enum TownArchetype {
	CATTLE_TOWN,
	MINING_CAMP,
	RIVER_CROSSING,
	BOOM_TOWN
}

enum ExitType {
	RIVER_CROSSING,
	MOUNTAIN_PASS,
	GORGE,
	BANDIT_CAMP,
	LONG_ROAD
}

# Core
@export var location_name: String = ""
@export var location_type: Type = Type.TOWN
@export var position: Vector2 = Vector2.ZERO
@export var visited: bool = false

# Town only
@export var archetype: TownArchetype = TownArchetype.CATTLE_TOWN
@export var has_sheriff: bool = false
@export var buildings: Array[String] = []
@export var regional_heat: int = 0

# Exit only
@export var exit_type: ExitType = ExitType.LONG_ROAD
@export var exit_difficulty: int = 0  # 0-2, affects crossing event

# Job state (town only)
var bank_job = null
var bank_completed: bool = false
var train_job = null
var train_completed: bool = false
var stagecoach_job = null
var stagecoach_completed: bool = false

# Social state (town only)
var recruit = null
var rumor: String = ""

# Building pools per archetype
const ARCHETYPE_BUILDINGS = {
	TownArchetype.CATTLE_TOWN: {
		"always": ["saloon"],
		"common": ["general_store", "stable"],
		"uncommon": ["bank", "gunsmith"],
		"rare": ["doctor", "train_station"]
	},
	TownArchetype.MINING_CAMP: {
		"always": ["saloon"],
		"common": ["general_store", "assay_office"],
		"uncommon": ["gunsmith", "bank"],
		"rare": ["doctor", "stable"]
	},
	TownArchetype.RIVER_CROSSING: {
		"always": ["saloon"],
		"common": ["general_store", "stable"],
		"uncommon": ["ferry_office", "train_station"],
		"rare": ["gunsmith", "bank"]
	},
	TownArchetype.BOOM_TOWN: {
		"always": ["saloon", "bank"],
		"common": ["general_store", "gunsmith"],
		"uncommon": ["stable", "train_station"],
		"rare": ["doctor"]
	}
}

# Name pools per type
const TOWN_NAMES = {
	TownArchetype.CATTLE_TOWN: {
		"prefixes": ["Red", "Dry", "Dusty", "Dead", "Iron", "Black", "Silver", "Lost"],
		"suffixes": ["Creek", "Gulch", "Ridge", "Flats", "Pass", "Fork", "Bluff", "Mesa"]
	},
	TownArchetype.MINING_CAMP: {
		"prefixes": ["Gold", "Copper", "Iron", "Tin", "Coal", "Ashen", "Burnt"],
		"suffixes": ["Vein", "Shaft", "Hollow", "Pit", "Gulch", "Claim", "Mine"]
	},
	TownArchetype.RIVER_CROSSING: {
		"prefixes": ["Muddy", "Swift", "Still", "Broken", "Shallow", "Deep"],
		"suffixes": ["Ford", "Crossing", "Bend", "Banks", "Landing", "Ferry"]
	},
	TownArchetype.BOOM_TOWN: {
		"prefixes": ["New", "Fort", "Grand", "High", "Big", "Last"],
		"suffixes": ["Hope", "Chance", "Strike", "Fortune", "Glory", "Stand"]
	}
}

const EXIT_NAMES = {
	ExitType.RIVER_CROSSING: ["Rio Perdido", "Bitter Creek Ford", "Dead Man's River"],
	ExitType.MOUNTAIN_PASS: ["Devil's Pass", "Widow's Peak", "The High Road"],
	ExitType.GORGE: ["Hangman's Gorge", "The Narrows", "Broken Rock Pass"],
	ExitType.BANDIT_CAMP: ["Cutthroat Hollow", "Raider's Rest", "The Ambush"],
	ExitType.LONG_ROAD: ["The Long Stretch", "Nowhere Road", "The Open Plain"]
}

const CAMP_NAMES = [
	"Outlaw Camp", "Drifter's Rest", "Dry Camp",
	"Hideout", "The Hollow", "Smuggler's Camp"
]

const CROSSROADS_NAMES = [
	"Broken Signpost", "The Fork", "Dusty Crossroads",
	"Old Junction", "Miller's Cross", "The Split"
]

func generate(pos: Vector2, type: Type, region_difficulty: int = 0) -> void:
	position = pos
	location_type = type

	match type:
		Type.TOWN:
			_generate_town(region_difficulty)
		Type.CAMP:
			location_name = CAMP_NAMES.pick_random()
		Type.CROSSROADS:
			location_name = CROSSROADS_NAMES.pick_random()
		Type.EXIT:
			_generate_exit(region_difficulty)

func _generate_town(region_difficulty: int) -> void:
	archetype = TownArchetype.values().pick_random()
	has_sheriff = randf() > (0.5 - region_difficulty * 0.1)
	location_name = _generate_town_name()
	buildings = []

	var pool = ARCHETYPE_BUILDINGS[archetype]
	buildings.append_array(pool["always"])
	for b in pool["common"]:
		if randf() > 0.3:
			buildings.append(b)
	for b in pool["uncommon"]:
		if randf() > 0.55:
			buildings.append(b)
	for b in pool["rare"]:
		if randf() > 0.8:
			buildings.append(b)

func _generate_exit(region_difficulty: int) -> void:
	exit_type = ExitType.values().pick_random()
	exit_difficulty = region_difficulty
	location_name = EXIT_NAMES[exit_type].pick_random()

func _generate_town_name() -> String:
	var pool = TOWN_NAMES[archetype]
	return pool["prefixes"].pick_random() + " " + pool["suffixes"].pick_random()
