extends Area2D

signal damage_receive(weapon, damage_value)		# Not Implemented yet (It's kinda symbolic code)

export (NodePath) var entity_path = ".."
onready var entity = get_node(entity_path)

func _ready():
	if (entity_path == null || entity_path == ""):
		if (entity_path.is_empty()):
			print("On HitBox, ready ERROR, entity_path != parent path, entity_path is empty")
		elif (entity_path == null):
			print("On HitBox, ready ERROR, entity_path != parent path, return as: " + str(entity_path))
		
		print("On HitBox, ready ERROR, get the right parent.path: " + str(get_parent().get_path()))
		#entity_path = get_parent().get_path()

func _on_Hitbox_area_entered(area):
	# I think (Hitboxies as Area2D) receive damage from others (DamageBoxies as Area2D), for example the DamageBox of a weapon looking for a HitBox to give It some damage
	# If area is a DamageBox them call some func like was_damage(), set_damage() or something like that
	emit_signal("damage_receive", area.name, area.damage_value)		# Not Implemented yet (It's kinda symbolic code)

func _on_Hitbox_area_exited(area):
	# I don't think this is useful, but when the parent of "this/self" receive damage, It's very common It survive, so this could be used for somethink after damage (maybe check when the attack is over, It was just a short hit or a long hit (like some kamehameha lol)
	pass # Replace with function body.
