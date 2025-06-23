extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
var speed = 100
var last_direction = "down"

func _physics_process(delta):
	movement()

func movement():
	var mov = Vector2.ZERO
	mov.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	mov.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if mov != Vector2.ZERO:
		mov = mov.normalized()
		velocity = mov * speed
		
		# Only change animation if not attacking or attack animation has finished
		if not sprite.animation.begins_with("attack_") or not sprite.is_playing():
			if abs(mov.y) > abs(mov.x):
				if mov.y > 0:
					sprite.play("walk_down")
					last_direction = "down"
				elif mov.y < 0:
					sprite.play("walk_up")
					last_direction = "up"
			else:
				if mov.x > 0:
					sprite.play("walk_side")
					sprite.flip_h = false
					last_direction = "right"
				elif mov.x < 0:
					sprite.play("walk_side")
					sprite.flip_h = true
					last_direction = "left"
	else:
		# Idle animation based on last direction
		if not sprite.animation.begins_with("attack_") or not sprite.is_playing():
			if last_direction == "down":
				sprite.play("idle_down")
				sprite.flip_h = false
			elif last_direction == "up":
				sprite.play("idle_up")
				sprite.flip_h = false
			elif last_direction == "right":
				sprite.play("idle_side")
				sprite.flip_h = false
			elif last_direction == "left":
				sprite.play("idle_side")
				sprite.flip_h = true
		velocity = Vector2.ZERO
	
	move_and_slide()

func _input(event):
	if event.is_action_pressed("attack"):
		if last_direction == "down":
			sprite.play("attack_down")
		elif last_direction == "up":
			sprite.play("attack_up")
		elif last_direction == "right":
			sprite.play("attack_side")
			sprite.flip_h = false
		elif last_direction == "left":
			sprite.play("attack_side")
			sprite.flip_h = true
