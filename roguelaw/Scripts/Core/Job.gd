extends Node2D

@onready var job_title = $UI/JobTitle
@onready var job_description = $UI/JobDescription
@onready var crew_list = $UI/CrewList
@onready var result_label = $UI/ResultLabel
@onready var execute_btn = $UI/ExecuteButton
@onready var continue_btn = $UI/ContinueButton

var job: JobData

func _ready() -> void:
	job = RunData.current_job
	if job == null:
		return
	
	var type_names = ["Bank Robbery", "Train Heist", "Stagecoach Holdup"]
	job_title.text = type_names[job.job_type]
	job_description.text = job.description
	
	var chance = _resolve_job_preview()
	job_description.text = job.description + "\nSuccess chance: %d%%" % int(chance * 100)
	
	result_label.visible = false
	continue_btn.visible = false
	
	execute_btn.text = "Execute"
	execute_btn.pressed.connect(_on_execute_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	
	_populate_crew()

func _resolve_job_preview() -> float:
	var chance = 0.5
	chance += RunData.crew.size() * 0.1
	match job.difficulty:
		JobData.Difficulty.EASY:
			chance += 0.2
		JobData.Difficulty.MEDIUM:
			pass
		JobData.Difficulty.HARD:
			chance -= 0.2
	return clamp(chance, 0.0, 1.0)

func _populate_crew() -> void:
	for child in crew_list.get_children():
		child.queue_free()
	if RunData.crew.is_empty():
		var label = Label.new()
		label.text = "Riding alone."
		crew_list.add_child(label)
	else:
		for member in RunData.crew:
			var label = Label.new()
			var role_name = CrewMember.Role.keys()[member.role].capitalize()
			label.text = "%s — %s" % [member.member_name, role_name]
			crew_list.add_child(label)

func _on_execute_pressed() -> void:
	if RunData.health <=0:
		result_label.text = "\nYou didn't make it out."
		result_label.visible = true
		continue_btn.visible = false
		await get_tree().create_timer(3.0).timeout
		GameState.trigger_death("Shot during a job.")
		return
	execute_btn.visible = false
	var success = _resolve_job()
	
	if success:
		var payout = job.payout
		for member in RunData.crew:
			if member.role == CrewMember.Role.SAFECRACKER and job.job_type == JobData.Type.BANK:
				payout = int(payout * 1.25)
		RunData.add_money(payout)
		RunData.reputation += 10
		match job.job_type:
			JobData.Type.BANK:
				RunData.current_town.bank_completed = true
			JobData.Type.TRAIN:
				RunData.current_town.train_completed = true
		result_label.text = "Success. You got away with $%d." % payout
	else:
		var damage = randi_range(20, 50)
		RunData.take_damage(damage)
		result_label.text = "It went loud. You took %d damage." % damage
		if RunData.health <= 0:
			result_label.text += "\nYou didn't make it out."
			result_label.visible = true
			continue_btn.visible = false
			await get_tree().create_timer(3.0).timeout
			GameState.trigger_death("Shot during a job.")
			return
	
	var heat = job.heat_gain
	for member in RunData.crew:
		if member.role == CrewMember.Role.LOOKOUT:
			heat = int(heat * 0.7)
	RunData.add_heat(heat)
	result_label.visible = true
	continue_btn.text = "Ride Out"
	continue_btn.visible = true

func _resolve_job() -> bool:
	var chance = 0.5
	match job.difficulty:
		JobData.Difficulty.EASY:
			chance += 0.2
		JobData.Difficulty.MEDIUM:
			pass
		JobData.Difficulty.HARD:
			chance -= 0.2
	for member in RunData.crew:
		match member.role:
			CrewMember.Role.GUNSLINGER:
				chance += 0.08
			CrewMember.Role.SAFECRACKER:
				if job.job_type == JobData.Type.BANK:
					chance += 0.15
				else:
					chance += 0.05
			CrewMember.Role.LOOKOUT:
				chance += 0.08
			CrewMember.Role.MUSCLE:
				chance += 0.12
	return randf() < clamp(chance, 0.0, 1.0)

func _on_continue_pressed() -> void:
	GameState.change_state(GameState.State.MAP)
