extends CanvasLayer

func _ready():
	print("on PauseSceen now!")
	set_visible(false)
	layer = 9

func _input(event):
	#print("on PauseScreen, _input() says, heyyyyyyyyy!")
	if (event.is_action_pressed("ui_pause")):	# When key "P" is pressed
		set_visible(!get_tree().paused)		# if not pause then hide
		get_tree().paused = !get_tree().paused

func _on_Button_pressed():
	get_tree().paused = false
	set_visible(false)

func set_visible(is_visible):
	for node in get_children():
		node.visible = is_visible

func _on_FullScreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
