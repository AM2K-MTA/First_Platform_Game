extends Node

signal rupees_changed(count)
signal esmerald_changed(count)
signal bomb_changed(count)

export(int) var rupees = 0
export(int) var esmerald = 0
export(int) var bomb = 0

func _ready():
	emit_signal("rupees_changed", rupees)
	emit_signal("esmerald_changed", esmerald)
	emit_signal("bomb_changed", bomb)

func _on_CollectArea_item_collected(item):
	rupees += 1
	emit_signal("rupees_changed", rupees)

# mod
func item_collected(item, item_id : String):
	print(str(item.name) + " collected, name is: " + item_id)
	if (item_id == "Esmerald"):
		esmerald += 1
		emit_signal("esmerald_changed", esmerald)
	elif (item_id == "Bomb"):
		bomb += 1
		emit_signal("bomb_changed", bomb)
