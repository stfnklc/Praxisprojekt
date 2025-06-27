extends Area2D

@export var damage = 10
@onready var collision_shape = $CollisionShape2D

func _ready():
	monitoring = false 
	print("Hitbox _ready, monitoring: ", monitoring)

func activate(duration):
	print("Activating Hitbox for ", duration, " seconds")
	monitoring = true
	await get_tree().create_timer(duration).timeout
	monitoring = false
	print("Deactivating Hitbox")

func get_damage():
	return damage
