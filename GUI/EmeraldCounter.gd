extends MarginContainer

func _on_GUI_esmerald_changed(count):
	$Background/Number.text = str(count)
