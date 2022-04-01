extends Node2D

signal throw_item()

signal end_throw_anim_signal()

signal end_death_anim_signal()

# throw_Donuts --> animation
signal throw_signal()
signal end_throw_donut_anim_signal()

onready var held_item_position = $Torso/RightArm/HeldItemPosition


func _on_Punch_hit_area_entered(area):
	if (area.is_in_group("DamageBox")):
		if (area.has_method("take_damage")):
			print("On player/CharacterRig, area of DamageBox group is colliding, call his func take_damage()!")
			area.take_damage("atk_simple", 5)
