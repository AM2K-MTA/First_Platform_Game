extends MarginContainer

func _on_GUI_bomb_changed(count):
	$Background/Number.text = str(count)
