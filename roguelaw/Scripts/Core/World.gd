extends Node2D

@onready var town_nodes = $RegionMap/TownNodes
@onready var name_label = $UI/PlayerInfo/NameLabel
@onready var money_label = $UI/PlayerInfo/MoneyLabel
@onready var heat_label = $UI/PlayerInfo/HeatLabel
@onready var health_label = $UI/PlayerInfo/HealthLabel
@onready var crew_label = $UI/PlayerInfo/CrewLabel

const NUM_TOWNS = 6
var towns: Array[TownData] = []
var connections: Array = []

func _ready() -> void:
	$RegionMap.position = Vector2.ZERO
	if not RunData.region_generated:
		_generate_region()
	else:
		towns = RunData.towns
		connections = RunData.connections
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
	health_label.text = "Health: " +str(RunData.health)
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

func _generate_region() -> void:
	towns.clear()
	connections.clear()

	var positions = [
	Vector2(-145, -75),
	Vector2(5, -95),
	Vector2(155, -45),
	Vector2(-125, 75),
	Vector2(25, 85),
	Vector2(165, 105)
	]

	for pos in positions:
		var town = TownData.new()
		town.generate(pos)
		towns.append(town)

	connections = [
		[0,1],[1,2],[0,3],[1,4],[2,5],[3,4],[4,5]
	]

	_draw_map()
	
	RunData.towns = towns
	RunData.connections = connections
	RunData.region_generated = true

func _draw_map() -> void:
	for child in town_nodes.get_children():
		child.queue_free()
	for i in range(towns.size()):
		var btn = Button.new()
		btn.text = towns[i].town_name
		btn.position = towns[i].position
		btn.pressed.connect(_on_town_clicked.bind(i))
		town_nodes.add_child(btn)
	queue_redraw()

func _on_town_clicked(index: int) -> void:
	var town = towns[index]
	RunData.current_town = town
	EventBus.town_entered.emit(town)
	GameState.change_state(GameState.State.RIDE)

func _draw() -> void:
	for conn in connections:
		var a = towns[conn[0]].position
		var b = towns[conn[1]].position
		draw_line(a, b, Color.WHITE, 1.0)
