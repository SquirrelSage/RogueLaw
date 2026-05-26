extends Node2D

@onready var town_nodes = $RegionMap/TownNodes
@onready var name_label = $UI/PlayerInfo/NameLabel
@onready var money_label = $UI/PlayerInfo/MoneyLabel
@onready var heat_label = $UI/PlayerInfo/HeatLabel
@onready var health_label = $UI/PlayerInfo/HealthLabel
@onready var crew_label = $UI/PlayerInfo/CrewLabel

var current_location_index: int = 0

func _ready() -> void:
	$RegionMap.position = Vector2.ZERO
	if not RunData.region_generated:
		_generate_region()
	else:
		current_location_index = RunData.current_location_index
	_draw_map()
	_update_ui()
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.heat_changed.connect(_on_heat_changed)
	EventBus.health_changed.connect(_on_health_changed)
	EventBus.crew_member_added.connect(_on_crew_changed)
	EventBus.crew_member_died.connect(_on_crew_changed)

func _update_ui() -> void:
	name_label.text = RunData.player_name
	money_label.text = "$" + str(RunData.money)
	heat_label.text = "Heat: " + str(RunData.global_heat)
	health_label.text = "Health: " + str(RunData.health)
	_update_crew_label()

func _update_crew_label() -> void:
	if RunData.crew.is_empty():
		crew_label.text = "Crew: none"
	else:
		var names = []
		for m in RunData.crew:
			names.append(m.member_name)
		crew_label.text = "Crew: " + ", ".join(names)

func _on_money_changed(new_amount: int) -> void:
	money_label.text = "$" + str(new_amount)

func _on_heat_changed(new_amount: int) -> void:
	heat_label.text = "Heat: " + str(new_amount)

func _on_health_changed(new_amount: int) -> void:
	health_label.text = "Health: " + str(new_amount)

func _on_crew_changed(_member) -> void:
	_update_crew_label()

func _get_neighbors(index: int) -> Array:
	var neighbors = []
	for conn in RunData.current_region.connections:
		if conn[0] == index:
			neighbors.append(conn[1])
		elif conn[1] == index:
			neighbors.append(conn[0])
	return neighbors

func _generate_region() -> void:
	var region = RegionData.new()
	var type = RegionData.Type.values()[RunData.region_index]
	region.generate(type)
	RunData.current_region = region
	RunData.current_location_index = 0
	RunData.region_generated = true
	current_location_index = 0

func _draw_map() -> void:
	for child in town_nodes.get_children():
		child.queue_free()

	var region = RunData.current_region
	if region == null:
		return

	var neighbors = _get_neighbors(current_location_index)

	for i in range(region.locations.size()):
		var loc = region.locations[i]
		var btn = Button.new()
		btn.position = loc.position

		# Label by type
		match loc.location_type:
			LocationData.Type.TOWN:
				btn.text = loc.location_name
			LocationData.Type.CAMP:
				btn.text = "⛺ " + loc.location_name
			LocationData.Type.CROSSROADS:
				btn.text = "✦ " + loc.location_name
			LocationData.Type.EXIT:
				btn.text = "➤ " + loc.location_name

		if i == current_location_index:
			btn.text = "★ " + btn.text
			btn.disabled = true
		elif i in neighbors:
			btn.pressed.connect(_on_location_clicked.bind(i))
		else:
			btn.disabled = true
			btn.modulate = Color(0.4, 0.4, 0.4)

		town_nodes.add_child(btn)

	queue_redraw()

func _on_location_clicked(index: int) -> void:
	var region = RunData.current_region
	var loc = region.locations[index]

	current_location_index = index
	RunData.current_location_index = index
	RunData.current_location = loc

	# Exit node — move to next region
	if loc.location_type == LocationData.Type.EXIT:
		_enter_exit(loc)
		return

	# Camp — no town scene, just a quick event (stub for now)
	if loc.location_type == LocationData.Type.CAMP:
		RunData.current_location = loc
		EventBus.town_entered.emit(loc)
		GameState.change_state(GameState.State.TOWN)
		return

	# Crossroads — travel event only (stub for now, goes to town)
	if loc.location_type == LocationData.Type.CROSSROADS:
		RunData.current_location = loc
		EventBus.town_entered.emit(loc)
		GameState.change_state(GameState.State.TOWN)
		return

	# Town — ride then enter
	EventBus.town_entered.emit(loc)
	GameState.change_state(GameState.State.RIDE)

func _enter_exit(loc: LocationData) -> void:
	# Stub — crossing event will go here
	# For now just generate next region and reload map
	RunData.region_index += 1
	if RunData.region_index >= RegionData.Type.size():
		RunData.region_index = RegionData.Type.size() - 1
	RunData.region_generated = false
	RunData.current_location_index = 0
	current_location_index = 0
	_generate_region()
	_draw_map()

func _draw() -> void:
	var region = RunData.current_region
	if region == null:
		return
	for conn in region.connections:
		var a = region.locations[conn[0]].position
		var b = region.locations[conn[1]].position
		draw_line(a, b, Color.WHITE, 1.0)
