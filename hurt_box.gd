extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var disable_timer = $DisableTimer

var HurtBoxType = 0 
var last_hit_time = 0.0
var hit_cooldown = 0.5  

func _ready():
	area_entered.connect(_on_area_entered)
	disable_timer.timeout.connect(_on_disable_timer_timeout)
	print("Hurtbox initialized, HurtBoxType: ", HurtBoxType)

func _on_area_entered(area):
	if area.is_in_group("Hitbox"):
		
		if area.owner == owner:
			print("Ignoring self-hit from: ", area.name)
			return
		print("Hurtbox detected Hitbox: ", area.name)
		var current_time = Time.get_ticks_msec() / 1000.0
		match HurtBoxType:
			0: 
				collision_shape.set_deferred("disabled", true)
				disable_timer.start(0.5)  
				print("Hurtbox disabled for 0.5s")
			1: 
				if current_time - last_hit_time >= hit_cooldown:
					last_hit_time = current_time
				else:
					return
			2: 
				if area.has_method("activate"):
					area.activate(0.5)  
		if area.has_method("get_damage"):
			var damage = area.get_damage()
			if owner and owner.has_method("take_damage"):
				owner.take_damage(damage)

func _on_disable_timer_timeout():
	collision_shape.set_deferred("disabled", false)
	print("Hurtbox re-enabled")
