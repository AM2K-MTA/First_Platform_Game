extends Area2D

# "string_atk_type" get the attack type received, like "magic, weapon, item, etc" or It's a simple atk or a special (can this/self defend that attack or It's indenfensible)
func take_damage(string_atk_type, int_damage_take):
	print("On ", self.name, ", child of Golem, Golem_HurtBox.gd, func take_damge, atk_type: " + str(string_atk_type) + ", int_damage_take: " + str(int_damage_take))

func _on_HurtBox_area_entered(area):
	if (area.get_parent() != self.get_parent()):
#		print("__________On ", self.name, ", child of Golem, Golem_HurtBox.gd, HurtBox area entered, area is a my parent: ", area.get_parent().name)
		if (area.is_in_group("HitBox")):
			print("On ", self.name, ", child of Golem, Golem_HurtBox.gd, HurtBox area entered, THAT HURTS!... Area is: " + str(area.name))
