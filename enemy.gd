extends CharacterBody2D

@export var speed = 20.0
@export var hp = 150.0  
@export var damage = 10.0

@onready var sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox

var player = null
var is_attacking = false
var is_initialized = false

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
		print("Enemy found player at: ", player.position)
	else:
		print("Enemy WARNING: No player found in 'Player' group!")
	sprite.play("idle")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	hurtbox.HurtBoxType = 0  
	hitbox.monitoring = false
	print("Enemy initialized, Hitbox monitoring: ", hitbox.monitoring)
	await get_tree().physics_frame  
	is_initialized = true

func _physics_process(delta):
	if player and hp > 0 and is_initialized:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		
		if velocity.length() > 0 and not is_attacking:
			sprite.play("moving")
		elif not is_attacking:
			sprite.play("idle")
		
		move_and_slide()
		
		var distance_to_player = player.position.distance_to(position)
		if distance_to_player < 30.0 and not is_attacking:
			is_attacking = true
			print("Hitbox activated, distance: ", distance_to_player)
		elif distance_to_player >= 30.0 and is_attacking:
			is_attacking = false
			hitbox.monitoring = false
			print("Hitbox deactivated, distance: ", distance_to_player)
	
	if hp <= 0:
		queue_free()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Hitbox"):
		print("Enemy taking damage from: ", area.name, " with damage: ", area.damage)
		take_damage(area.damage)

func take_damage(incoming_damage):
	hp -= incoming_damage
	print("Enemy HP: ", hp)
