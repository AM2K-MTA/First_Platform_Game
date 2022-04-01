extends Area2D

# "string_atk_type" get the attack type received, like "magic, weapon, item, etc" or It's a simple atk or a special (can this/self defend that attack or It's indenfensible)
func take_damage(string_atk_type, int_damage_take):
	print("On HurtBox, child of Golem, func take_damge, atk_type: " + str(string_atk_type) + ", int_damage_take: " + str(int_damage_take))

func _on_HurtBox_area_entered(area):
	if (area.is_in_group("HitBox")):
		print("On HurtBox, child of Golem, HitBox area entered, THAT HURTS!... Area is: " + str(area.name))
