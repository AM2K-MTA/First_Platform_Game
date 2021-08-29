extends Node2D

var bonus_height = Globals.UNIT_SIZE * 2
var effect_duration = 5

func _on_area2D_area_entered(area):
	# disable area
	$Area2D.queue_free()
	# Hide Power-up
	visible = false
	
	var entity = area.get_parent()
	# Store default velocity (probabilly not the best way to do this, might need to make a variable for this in player controller).
	var temp = entity.max_jump_velocity
	# set new velocity with bonus height added.
	entity.max_jump_velocity = -sqrt(2 * entity.gravity * (entity.max_jump_height + bonus_height))
	# Yield until duration has passed so that the script can clean up afterwards.
	yield(get_tree().create_timer(effect_duration), "timeout")
	# Restore the previous jump velocity.
	entity.max_jump_velocity = temp
	# Delete self.
	queue_free()
	
