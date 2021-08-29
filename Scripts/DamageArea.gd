extends Area2D

signal entity_damaged(entity)

export (float) var damage_amount = 1

var exceptions = []

func add_exception(node : Node):
	exceptions.append(node)

func remove_exception(node : Node):
	exceptions.erase(node)

func _on_damageArea_area_entered(area):
	if area is Hitbox:
		if (!exceptions.has(area.entity) and area.entity.has_method("damage")):
			area.entity.damage(damage_amount, self)
