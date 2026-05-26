extends Node2D

@onready var location_name_label = $UI/TownName
@onready var sheriff_label = $UI/SheriffLabel
@onready var buildings_container = $UI/Buildings
@onready var back_button = $UI/BackButton
@onready var building_panel = $UI/BuildingPanel
@onready var building_title = $UI/BuildingPanel/VBox/BuildingTitle
@onready var building_content = $UI/BuildingPanel/VBox/BuildingContent
@onready var close_button = $UI/BuildingPanel/VBox/CloseButton

func _ready() -> void:
	var town = RunData.current_location
	if town == null:
		return
	location_name_label.text = town.location_name
	sheriff_label.text = "Sheriff: YES" if town.has_sheriff else "Sheriff: NO"
	back_button.text = "Leave Town"
	back_button.pressed.connect(_on_back_pressed)
	close_button.text = "Close"
	close_button.pressed.connect(_close_panel)
	building_panel.visible = false
	_populate_buildings(town)

func _populate_buildings(town) -> void:
	for child in buildings_container.get_children():
		child.queue_free()
	for building in town.buildings:
		var btn = Button.new()
		btn.text = building.capitalize().replace("_", " ")
		btn.pressed.connect(_on_building_clicked.bind(building))
		buildings_container.add_child(btn)

func _on_building_clicked(building: String) -> void:
	EventBus.building_entered.emit(building)
	_open_building(building)

func _open_building(building: String) -> void:
	building_panel.visible = true
	building_title.text = building.capitalize().replace("_", " ")
	for child in building_content.get_children():
		child.queue_free()
	match building:
		"saloon":
			_build_saloon()
		"general_store":
			_build_general_store()
		"stable":
			_build_stable()
		"bank":
			_build_bank()
		"gunsmith":
			_build_gunsmith()
		"doctor":
			_build_doctor()
		"train_station":
			_build_train_station()
		_:
			_build_placeholder(building)

func _build_placeholder(building: String) -> void:
	var label = Label.new()
	label.text = "Nothing here yet."
	building_content.add_child(label)

func _build_saloon() -> void:
	var label = Label.new()
	label.text = "Dark inside. Smells like whiskey."
	building_content.add_child(label)
	
	# Current crew with fire buttons
	if not RunData.crew.is_empty():
		var roster_label = Label.new()
		roster_label.text = "--- Your Crew ---"
		building_content.add_child(roster_label)
		for member in RunData.crew.duplicate():
			var hbox = HBoxContainer.new()
			var name_label = Label.new()
			var role_name = CrewMember.Role.keys()[member.role].capitalize()
			name_label.text = "%s — %s" % [member.member_name, role_name]
			var fire_btn = Button.new()
			fire_btn.text = "Fire"
			fire_btn.pressed.connect(_on_fire_pressed.bind(member))
			hbox.add_child(name_label)
			hbox.add_child(fire_btn)
			building_content.add_child(hbox)
	
	# Rumor — lock to town
	if RunData.current_location.rumor == "":
		var rumors = [
			"The bank in the next town runs a skeleton crew on Sundays.",
			"Heard a payroll shipment comes through on the eastern pass.",
			"Sheriff two towns over got reassigned. Nobody replaced him.",
			"Train's carrying silver ore. Light on guards."
		]
		RunData.current_location.rumor = rumors.pick_random()
	var rumor_label = Label.new()
	rumor_label.text = "\"%s\"" % RunData.current_location.rumor
	rumor_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	building_content.add_child(rumor_label)
	
	# Recruit — lock to town
	if RunData.current_location.recruit == null:
		RunData.current_location.recruit = CrewMember.generate()
	var recruit = RunData.current_location.recruit
	
	const ROLE_DESC = {
	"GUNSLINGER": "Reduces damage taken on failed jobs.",
	"SAFECRACKER": "Boosts payout on bank jobs.",
	"LOOKOUT": "Reduces heat gained after jobs.",
	"MUSCLE": "Increases base success chance."
	}
	
	if RunData.crew.size() < RunData.max_crew:
		var role_name = CrewMember.Role.keys()[recruit.role].capitalize()
		var role_key = CrewMember.Role.keys()[recruit.role]
		var recruit_label = Label.new()
		recruit_label.text = "%s — %s — $%d" % [recruit.member_name, role_name, recruit.hire_cost]
		building_content.add_child(recruit_label)
		var desc_label = Label.new()
		desc_label.text = ROLE_DESC.get(role_key, "")
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		building_content.add_child(desc_label)
		var hire_btn = Button.new()
		hire_btn.text = "Hire"
		hire_btn.pressed.connect(_on_hire_pressed.bind(recruit, hire_btn, recruit_label))
		building_content.add_child(hire_btn)
	else:
		var full_label = Label.new()
		full_label.text = "Crew is full."
		building_content.add_child(full_label)

func _on_fire_pressed(member: CrewMember) -> void:
	RunData.crew.erase(member)
	EventBus.crew_member_died.emit(member)
	_open_building("saloon")

func _on_hire_pressed(recruit: CrewMember, btn: Button, lbl: Label) -> void:
	if RunData.spend_money(recruit.hire_cost):
		RunData.crew.append(recruit)
		RunData.current_location.recruit = null
		EventBus.crew_member_added.emit(recruit)
		btn.queue_free()
		lbl.text = "%s hired." % recruit.member_name
	else:
		btn.text = "Can't afford"

func _build_general_store() -> void:
	var label = Label.new()
	label.text = "Shelves of supplies."
	building_content.add_child(label)
	
	var ammo_label = Label.new()
	ammo_label.text = "Ammo: %d" % RunData.supplies["ammo"]
	building_content.add_child(ammo_label)
	
	var buy_ammo_btn = Button.new()
	buy_ammo_btn.text = "Buy ammo (12) — $10"
	buy_ammo_btn.pressed.connect(_on_buy_ammo.bind(ammo_label))
	building_content.add_child(buy_ammo_btn)
	
	var buy_dynamite_btn = Button.new()
	buy_dynamite_btn.text = "Buy dynamite (1) — $30"
	buy_dynamite_btn.pressed.connect(_on_buy_dynamite)
	building_content.add_child(buy_dynamite_btn)

func _on_buy_ammo(ammo_label: Label) -> void:
	if RunData.spend_money(10):
		RunData.supplies["ammo"] += 12
		ammo_label.text = "Ammo: %d" % RunData.supplies["ammo"]
	else:
		pass

func _on_buy_dynamite() -> void:
	if RunData.spend_money(30):
		RunData.supplies["dynamite"] += 1
	else:
		pass

func _build_stable() -> void:
	var desc = Label.new()
	desc.text = "Horses for sale."
	building_content.add_child(desc)
	
	var current = Label.new()
	current.text = "Your mount: %s (Stamina: %d)" % [_get_horse_name(), RunData.horse_stamina]
	building_content.add_child(current)
	
	# Rest horse
	if RunData.horse_stamina < 100:
		var rest_btn = Button.new()
		rest_btn.text = "Rest horse — $5"
		rest_btn.pressed.connect(_on_rest_horse.bind(current))
		building_content.add_child(rest_btn)
	
	# Buy better horse
	if RunData.horse_tier == 0:
		var buy_btn = Button.new()
		buy_btn.text = "Buy Quarterhorse — $150"
		buy_btn.pressed.connect(_on_buy_horse.bind(1, "res://Assets/Sprites/horse_quarter.png", buy_btn, current))
		building_content.add_child(buy_btn)
	elif RunData.horse_tier == 1:
		var buy_btn = Button.new()
		buy_btn.text = "Buy Thoroughbred — $400"
		buy_btn.pressed.connect(_on_buy_horse.bind(2, "res://Assets/Sprites/horse_thorough.png", buy_btn, current))
		building_content.add_child(buy_btn)
	else:
		var label = Label.new()
		label.text = "Finest horse in the territory."
		building_content.add_child(label)

func _get_horse_name() -> String:
	match RunData.horse_tier:
		0: return "Mule"
		1: return "Quarterhorse"
		2: return "Thoroughbred"
	return "Unknown"

func _on_rest_horse(current_label: Label) -> void:
	if RunData.spend_money(5):
		RunData.horse_stamina = 100
		current_label.text = "Your mount: %s (Stamina: %d)" % [_get_horse_name(), RunData.horse_stamina]
	else:
		pass

func _on_buy_horse(tier: int, sprite: String, btn: Button, current_label: Label) -> void:
	var costs = [0, 150, 400]
	if RunData.spend_money(costs[tier]):
		RunData.horse_tier = tier
		RunData.horse_sprite = sprite
		RunData.horse_stamina = 100
		EventBus.horse_changed.emit()
		btn.queue_free()
		current_label.text = "Your mount: %s (Stamina: 100)" % _get_horse_name()

func _build_bank() -> void:
	var label = Label.new()
	label.text = "Vault in the back. Guards by the door."
	building_content.add_child(label)
	
	if RunData.current_location.bank_completed:
		var done_label = Label.new()
		done_label.text = "Already hit this bank. Move on."
		building_content.add_child(done_label)
		return
	
	if RunData.current_location.bank_job == null:
		RunData.current_location.bank_job = JobData.generate(JobData.Type.BANK, _get_difficulty())
	RunData.current_job = RunData.current_location.bank_job
	
	var desc = Label.new()
	desc.text = RunData.current_job.description
	building_content.add_child(desc)
	
	var rob_btn = Button.new()
	rob_btn.text = "Rob the Bank"
	rob_btn.pressed.connect(_on_job_pressed)
	building_content.add_child(rob_btn)

func _build_train_station() -> void:
	var label = Label.new()
	label.text = "Schedule on the board."
	building_content.add_child(label)
	
	if RunData.current_location.train_completed:
		var done_label = Label.new()
		done_label.text = "Already hit the train. Move on."
		building_content.add_child(done_label)
		return
	
	if RunData.current_location.train_job == null:
		RunData.current_location.train_job = JobData.generate(JobData.Type.TRAIN, _get_difficulty())
	RunData.current_job = RunData.current_location.train_job
	
	var desc = Label.new()
	desc.text = RunData.current_job.description
	building_content.add_child(desc)
	
	var rob_btn = Button.new()
	rob_btn.text = "Hit the Train"
	rob_btn.pressed.connect(_on_job_pressed)
	building_content.add_child(rob_btn)

func _get_difficulty() -> int:
	if RunData.reputation < 20:
		return JobData.Difficulty.EASY
	elif RunData.reputation < 50:
		return JobData.Difficulty.MEDIUM
	else:
		return JobData.Difficulty.HARD

func _on_job_pressed() -> void:
	GameState.change_state(GameState.State.JOB)

func _build_gunsmith() -> void:
	var label = Label.new()
	label.text = "Guns on the wall."
	building_content.add_child(label)

func _build_doctor() -> void:
	var label = Label.new()
	label.text = "Smells like antiseptic."
	building_content.add_child(label)
	
	var health_label = Label.new()
	health_label.text = "Your health: %d" % RunData.health
	building_content.add_child(health_label)
	
	if RunData.health >= 100:
		var fine_label = Label.new()
		fine_label.text = "You're fine. Move on."
		building_content.add_child(fine_label)
	else:
		var heal_btn = Button.new()
		heal_btn.text = "Patch up — $25"
		heal_btn.pressed.connect(_on_heal_pressed.bind(health_label, heal_btn))
		building_content.add_child(heal_btn)

func _on_heal_pressed(health_label: Label, btn: Button) -> void:
	if RunData.spend_money(25):
		RunData.health = min(100, RunData.health + 50)
		EventBus.health_changed.emit(RunData.health)
		health_label.text = "Your health: %d" % RunData.health
		btn.text = "Patched up."
		btn.disabled = true
	else:
		btn.text = "Can't afford"

func _close_panel() -> void:
	building_panel.visible = false

func _on_back_pressed() -> void:
	GameState.change_state(GameState.State.MAP)
