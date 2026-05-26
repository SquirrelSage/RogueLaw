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
@export var difficulty: int = 0  # 0, 1, 2 — maps to EASY/MED/HARD jobs
@export var locations: Array = []
@export var connections: Array = []
@export var exit_indices: Array = []  # which location indices are exits

func generate(type: Type) -> void:
	region_type = type
	difficulty = type  # FRONTIER=0, OUTLAW=1, BORDER=2
	region_name = REGION_NAMES[type].pick_random()
	_generate_locations()

func _generate_locations() -> void:
	locations.clear()
	connections.clear()
	exit_indices.clear()

	var num_locations = randi_range(6, 9)

	# Location type mix — more towns than anything else
	var type_pool = []
	type_pool.append_array([LocationData.Type.TOWN, LocationData.Type.TOWN, LocationData.Type.TOWN])
	type_pool.append_array([LocationData.Type.CAMP, LocationData.Type.CROSSROADS])

	# Generate positions in a rough west-to-east spread
	for i in range(num_locations):
		var loc = LocationData.new()
		var col = i % 3
		var row = i / 3
		var pos = Vector2(
			-150 + col * 160 + randf_range(-30, 30),
			-80 + row * 120 + randf_range(-20, 20)
		)
		var type = type_pool[i % type_pool.size()]
		loc.generate(pos, type, difficulty)
		locations.append(loc)

	# Add 1-2 exit nodes at the far end
	var num_exits = randi_range(1, 2)
	for i in range(num_exits):
		var exit_loc = LocationData.new()
		var pos = Vector2(160 + i * 60, randf_range(-60, 60))
		exit_loc.generate(pos, LocationData.Type.EXIT, difficulty)
		exit_indices.append(locations.size())
		locations.append(exit_loc)

	# Build web connections — each node connects to 2-3 neighbors
	_generate_web_connections()

func _generate_web_connections() -> void:
	# Connect each location to its nearest neighbors
	for i in range(locations.size()):
		var distances = []
		for j in range(locations.size()):
			if i == j:
				continue
			var dist = locations[i].position.distance_to(locations[j].position)
			distances.append({"index": j, "dist": dist})
		distances.sort_custom(func(a, b): return a.dist < b.dist)

		# Connect to 2-3 nearest
		var connect_count = randi_range(2, 3)
		for k in range(min(connect_count, distances.size())):
			var j = distances[k].index
			var conn = [min(i,j), max(i,j)]
			if conn not in connections:
				connections.append(conn)

	# Ensure exit nodes are reachable
	for exit_idx in exit_indices:
		var connected = false
		for conn in connections:
			if exit_idx in conn:
				connected = true
				break
		if not connected:
			# Connect to nearest non-exit
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
