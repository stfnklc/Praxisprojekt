extends CharacterBody2D

@export var speed = 20.0
@export var hp = 50.0
@export var damage = 1.0

@onready var sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox

var player = null
var is_attacking = false

func _ready():
	# Find the player using the global "Player" group with debug
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
		print("Enemy found player at: ", player.position)
	else:
		print("Enemy WARNING: No player found in 'Player' group!")
	# Ensure the enemy starts with the idle animation
	sprite.play("idle")
	# Connect the Hurtbox signal
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	# Disable Hitbox by default
	hitbox.monitoring = false

func _physics_process(delta):
	if player and hp > 0:
		# Calculate direction toward the player with debug
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		#print("Enemy velocity: ", velocity)  # Debug velocity
		
		# Update animation based on movement
		if velocity.length() > 0 and not is_attacking:
			sprite.play("moving")
		elif not is_attacking:
			sprite.play("idle")
		
		move_and_slide()
		
		# Enable Hitbox when close to player
		var distance_to_player = player.position.distance_to(position)
		#print("Distance to player: ", distance_to_player)  # Debug distance
		if distance_to_player < 30.0 and not is_attacking:  # Increased from 20.0 to 30.0
			is_attacking = true
			hitbox.monitoring = true
			print("Hitbox activated, distance: ", distance_to_player)
		elif distance_to_player >= 30.0 and is_attacking:
			is_attacking = false
			hitbox.monitoring = false
			print("Hitbox deactivated, distance: ", distance_to_player)
	
	# Handle death
	if hp <= 0:
		queue_free()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Hitbox"):
		print("Enemy taking damage from: ", area.name, " with damage: ", area.damage)
		take_damage(area.damage)

func take_damage(damage):
	hp -= damage
	print("Enemy HP: ", hp)  # Debug HP
