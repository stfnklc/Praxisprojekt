extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var hurtbox = $Hurtbox
@onready var death_panel = $DeathPanel

var speed = 100
var hp = 50
var last_direction = "down"

func _ready():
	hitbox.monitoring = false
	hurtbox.HurtBoxType = 0  
	print("Player initialized, Hitbox monitoring: ", hitbox.monitoring)
	await get_tree().physics_frame  
	hurtbox.area_entered.connect(_on_hurtbox_area_entered) 

func _physics_process(_delta):
	movement()

func movement():
	var mov = Vector2.ZERO
	mov.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	mov.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if mov != Vector2.ZERO:
		mov = mov.normalized()
		velocity = mov * speed
		if not sprite.is_playing() or not sprite.animation.begins_with("attack_"):
			update_animation(mov)
	else:
		if not sprite.is_playing() or not sprite.animation.begins_with("attack_"):
			update_idle_animation()
		velocity = Vector2.ZERO
	
	move_and_slide()

func update_animation(mov):
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

func update_idle_animation():
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

func _input(event):
	if event.is_action_pressed("attack"):
		hitbox.monitoring = true
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
		hitbox.activate(0.5) 
		print("Player attack initiated, Hitbox activated")

func take_damage(damage):
	hp -= damage
	print("Player HP: ", hp)
	if hp <= 0:
		print("Player dying...")
		die()

func die():
	sprite.play("death")
	set_physics_process(false)
	hitbox.monitoring = false
	get_tree().paused = true
	death_panel.visible = true
	var tween = create_tween()
	tween.tween_property(death_panel, "modulate:a", 1.0, 1.0).from(0.0)
	await sprite.animation_finished
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Hitbox"):
		print("Player Hurtbox detected Hitbox: ", area.name)
		if area.owner != self:  
			take_damage(area.damage)
