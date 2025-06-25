extends Area2D

func _ready():
	# Connect the "area_entered" signal to the _on_area_entered method
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if area.is_in_group("hitbox"):
		owner.take_damage(area.damage)
