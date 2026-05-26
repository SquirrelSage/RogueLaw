class_name CrewMember
extends Resource

enum Role { GUNSLINGER, SAFECRACKER, LOOKOUT, MUSCLE }

@export var member_name: String = ""
@export var role: Role = Role.GUNSLINGER
@export var health: int = 100
@export var loyalty: int = 75
@export var hire_cost: int = 0

static func generate() -> CrewMember:
	var m = CrewMember.new()
	var first_names = ["Buck", "Clem", "Hoss", "Ike", "Otis", "Walt", "Silas", "Rudy"]
	var last_names = ["Pryor", "Dade", "Colt", "Finn", "Hale", "Knox", "Reed", "Vance"]
	m.member_name = first_names.pick_random() + " " + last_names.pick_random()
	m.role = Role.values().pick_random()
	m.health = 100
	m.loyalty = randi_range(50, 90)
	m.hire_cost = randi_range(10, 40)
	return m
