extends CharacterBody2D

const SPEED = 80

@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()
	
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		var current = anim.animation
		if current.begins_with("walk_"):
			anim.play("idle_" + current.substr(5))
	elif abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("walk_right")
		else:
			anim.play("walk_left")
	elif direction.y > 0:
		anim.play("walk_down")
	else:
		anim.play("walk_up")
