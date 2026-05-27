extends Node2D

@onready var horse_sprite = $HorseSprite
@onready var player_sprite = $PlayerSprite
@onready var ground = $Ground
@onready var background_rect = $Background/BackgroundLayer/BackgroundRect
@onready var stamina_label = $UI/StaminaLabel
@onready var destination_label = $UI/DestinationLabel
@onready var event_panel = $UI/EventPanel
@onready var event_label = $UI/EventPanel/VBox/EventLabel
@onready var event_options = $UI/EventPanel/VBox/EventOptions

var event_triggered = false
var scroll_speed = 200.0
var ride_distance = 0.0
var ride_length = 800.0
var riding = true

func _ready() -> void:
	# Setup background
	background_rect.color = Color(0.53, 0.67, 0.82)
	background_rect.size = Vector2(320, 100)
	
	# Setup ground
	ground.color = Color(0.6, 0.45, 0.25)
	ground.size = Vector2(320, 25)
	ground.position = Vector2(0, 100)
	
	# Load sprites
	horse_sprite.play("default")
	horse_sprite.scale = Vector2(1, 1)
	horse_sprite.position = Vector2(50, 97)
	horse_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	player_sprite.play("default")
	player_sprite.scale = Vector2(1, 1)
	player_sprite.position = Vector2(50, 88)
	player_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# spawn crew riders
	var crew_colors = [Color(1, 0.4, 0.4), Color(0.4, 1, 0.4), Color(0.4, 0.4, 1)]
	for i in range(RunData.crew.size()):
		var crew_horse = AnimatedSprite2D.new()
		crew_horse.sprite_frames = horse_sprite.sprite_frames
		crew_horse.play("default")
		crew_horse.scale = Vector2(1, 1)
		crew_horse.position = Vector2(50 - (20 * (i + 1)), 100)
		crew_horse.modulate = crew_colors[i % crew_colors.size()]
		crew_horse.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(crew_horse)
	
		var crew_sprite = AnimatedSprite2D.new()
		crew_sprite.sprite_frames = player_sprite.sprite_frames
		crew_sprite.play("default")
		crew_sprite.scale = Vector2(1, 1)
		crew_sprite.position = Vector2(50 - (20 * (i + 1)), 91)
		crew_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		crew_sprite.modulate = crew_colors[i % crew_colors.size()]
		add_child(crew_sprite)
	
	# UI
	stamina_label.position = Vector2(4, 4)
	destination_label.position = Vector2(4, 14)
	event_panel.visible = false
	event_panel.position = Vector2(50, 40)
	
	var dest = RunData.current_location
	destination_label.text = "Riding to: %s" % dest.location_name if dest else "Riding..."
	
	_update_stamina_label()
	
	#font stuff 
	var font = load("res://Assets/Fonts/m5x7.ttf")
	stamina_label.add_theme_font_override("font", font)
	stamina_label.add_theme_font_size_override("font_size", 8)
	destination_label.add_theme_font_override("font", font)
	destination_label.add_theme_font_size_override("font_size", 8)

func _process(delta: float) -> void:
	if not riding:
		return
	# Random event trigger around midpoint
	if ride_distance > ride_length * 0.4 and ride_distance < ride_length * 0.6 and not event_triggered:
		event_triggered = true
		if randf() < 0.5:
			_trigger_random_event()
	
	# Scroll background
	$Background.scroll_offset.x -= scroll_speed * delta
	
	# Deplete stamina
	ride_distance += scroll_speed * delta
	var stamina_cost = delta * 3.0
	match RunData.horse_tier:
		0: stamina_cost *= 2.0
		1: stamina_cost *= 1.0
		2: stamina_cost *= 0.5
	
	RunData.horse_stamina = max(0, RunData.horse_stamina - stamina_cost)
	_update_stamina_label()
	
	# Arrive at destination
	if ride_distance >= ride_length:
		riding = false
		_arrive()

func _update_stamina_label() -> void:
	stamina_label.text = "Stamina: %.1f" % RunData.horse_stamina

func _arrive() -> void:
	RunData.horse_stamina = min(100.0, RunData.horse_stamina +30.0)
	GameState.change_state(GameState.State.TOWN)

func _trigger_random_event() -> void:
	var roll = randf()
	if roll < 0.25:
		_event_stranger()
	elif roll < 0.5:
		_event_ambush()
	elif roll < 0.75:
		_event_wanted_poster()
	else:
		_event_injured_horse()

func _event_stranger() -> void:
	riding = false
	event_panel.visible = true
	event_label.text = "A stranger tips his hat. Hands you some information."
	for child in event_options.get_children():
		child.queue_free()
	var bonus = randi_range(10, 30)
	RunData.add_money(bonus)
	var cont = Button.new()
	cont.text = "Much obliged. ($%d richer)" % bonus
	cont.pressed.connect(_close_event)
	event_options.add_child(cont)

func _event_ambush() -> void:
	riding = false
	event_panel.visible = true
	event_label.text = "Bandits on the road. They want your money or your life."
	for child in event_options.get_children():
		child.queue_free()
	
	var fight_btn = Button.new()
	fight_btn.text = "Fight back"
	fight_btn.pressed.connect(_on_ambush_fight)
	event_options.add_child(fight_btn)
	
	var pay_btn = Button.new()
	pay_btn.text = "Pay them off"
	pay_btn.pressed.connect(_on_ambush_pay)
	event_options.add_child(pay_btn)

func _on_ambush_fight() -> void:
	var damage = randi_range(10, 30)
	RunData.take_damage(damage)
	event_label.text = "You fought them off. Took %d damage." % damage
	for child in event_options.get_children():
		child.queue_free()
	var cont = Button.new()
	cont.text = "Ride on"
	cont.pressed.connect(_close_event)
	event_options.add_child(cont)

func _on_ambush_pay() -> void:
	var loss = randi_range(20, 50)
	RunData.spend_money(loss)
	event_label.text = "Paid them off. Lost $%d." % loss
	for child in event_options.get_children():
		child.queue_free()
	var cont = Button.new()
	cont.text = "Ride on"
	cont.pressed.connect(_close_event)
	event_options.add_child(cont)

func _event_wanted_poster() -> void:
	riding = false
	event_panel.visible = true
	event_label.text = "You spot your face on a wanted poster. Heat: %d. They know who you are." % RunData.global_heat
	for child in event_options.get_children():
		child.queue_free()
	var cont = Button.new()
	cont.text = "Keep riding"
	cont.pressed.connect(_close_event)
	event_options.add_child(cont)

func _event_injured_horse() -> void:
	riding = false
	event_panel.visible = true
	var penalty = randi_range(15, 30)
	RunData.horse_stamina = max(0, RunData.horse_stamina - penalty)
	event_label.text = "Your horse stumbles on loose rock. Stamina down %d." % penalty
	for child in event_options.get_children():
		child.queue_free()
	var cont = Button.new()
	cont.text = "Easy now..."
	cont.pressed.connect(_close_event)
	event_options.add_child(cont)

func _close_event() -> void:
	event_panel.visible = false
	riding = true

func _on_flee() -> void:
	RunData.horse_stamina = max(0, RunData.horse_stamina - 20)
	event_panel.visible = false
	riding = true

func _on_stop() -> void:
	event_panel.visible = false
	riding = true
