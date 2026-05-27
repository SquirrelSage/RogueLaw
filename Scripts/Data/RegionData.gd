class_name RegionData
extends Resource

enum Type { FRONTIER, OUTLAW_COUNTRY, BORDER }

const REGION_NAMES = {
	Type.FRONTIER: ["The Frontier", "Open Range", "Dust Basin"],
	Type.OUTLAW_COUNTRY: ["Outlaw Country", "The Badlands", "Devil's Half Acre"],
	Type.BORDER: ["Border Territory", "The Rio Stretch", "Last Chance Land"]
}

@export var region_name: String = ""
@export var region_type: Type = Type.FRONTIER
@export var difficulty: int = 0
@export var locations: Array = []
@export var connections: Array = []
@export var exit_indices: Array = []

func generate(type: Type) -> void:
	region_type = type
	difficulty = type
	region_name = REGION_NAMES[type].pick_random()
	_generate_locations()

func _generate_locations() -> void:
	locations.clear()
	connections.clear()
	exit_indices.clear()

	var type_pool = [
		LocationData.Type.TOWN,
		LocationData.Type.TOWN,
		LocationData.Type.TOWN,
		LocationData.Type.CAMP,
		LocationData.Type.CROSSROADS
	]

	var column_x = [-90.0, -15.0, 60.0]
	var min_distance = 28.0
	var num_locations = randi_range(6, 8)

	# Place node 0 first — always left column, center
	var start_loc = LocationData.new()
	start_loc.generate(Vector2(-90, 0), LocationData.Type.TOWN, difficulty)
	locations.append(start_loc)

	# Generate remaining nodes
	for i in range(1, num_locations):
		var col = i % 3
		var pos = Vector2.ZERO
		var valid = false
		var attempts = 0

		while not valid and attempts < 100:
			pos = Vector2(
				column_x[col] + randf_range(-12, 12),
				randf_range(-50, 50)
			)
			valid = true
			for existing in locations:
				if pos.distance_to(existing.position) < min_distance:
					valid = false
					break
			attempts += 1

		var loc = LocationData.new()
		var type = type_pool[i % type_pool.size()]
		loc.generate(pos, type, difficulty)
		locations.append(loc)

	# Exit node — far right, guaranteed
	var exit_loc = LocationData.new()
	var exit_pos = Vector2(108, randf_range(-25, 25))
	exit_loc.generate(exit_pos, LocationData.Type.EXIT, difficulty)
	exit_indices.append(locations.size())
	locations.append(exit_loc)

	_generate_web_connections()

func _generate_web_connections() -> void:
	for i in range(locations.size()):
		var distances = []
		for j in range(locations.size()):
			if i == j:
				continue
			var dist = locations[i].position.distance_to(locations[j].position)
			distances.append({"index": j, "dist": dist})
		distances.sort_custom(func(a, b): return a.dist < b.dist)

		var connect_count = randi_range(2, 3)
		for k in range(min(connect_count, distances.size())):
			var j = distances[k].index
			var conn = [min(i, j), max(i, j)]
			if conn not in connections:
				connections.append(conn)

	# Guarantee exit is reachable
	for exit_idx in exit_indices:
		var connected = false
		for conn in connections:
			if exit_idx in conn:
				connected = true
				break
		if not connected:
			var nearest = -1
			var nearest_dist = INF
			for i in range(locations.size()):
				if i in exit_indices or i == exit_idx:
					continue
				var dist = locations[exit_idx].position.distance_to(locations[i].position)
				if dist < nearest_dist:
					nearest_dist = dist
					nearest = i
			if nearest != -1:
				connections.append([min(exit_idx, nearest), max(exit_idx, nearest)])
