extends Control

func _ready():
	visible = false

func _input(event):
	if (event.is_action_pressed("Pause")):		# temp is letter "O", this will sibstitute my "PauseScene.tscn"
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state
	
