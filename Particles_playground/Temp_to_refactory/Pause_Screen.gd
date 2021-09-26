extends Control

onready var continue_button = $CenterContainer/VBoxContainer/Continue_button
onready var open_levels_access_button = $CenterContainer/VBoxContainer/Open_levels_access_button

onready var level_teleport_window = $Levels_Teleport/Control
onready var levels_popup_menu = $Levels_Teleport/Control/CenterContainer/VBoxContainer/Popup/PopupMenu

var is_pause_screen_called = false

func _ready():
	print("______________________ Pause_Screen is ready!")
	get_tree().paused = false
	visible = false
	level_teleport_window.visible = false
	levels_popup_menu.visible = false
	continue_button.disabled = true
	open_levels_access_button.disabled = true

func _input(event : InputEvent) -> void:
	var find_current_level = get_tree().current_scene.get_node("Current_Scene").get_child(0)		# Get the current level
	if (is_pause_screen_called):
		#print(find_current_level.name)		# Get the current level name
		#print(event)
		#print(find_current_level.get_node("PauseScreen").name)		# Get the node PauseScreen.tscn
		get_tree().current_scene.get_node("Interface").get_node("PauseScreen").set_process_input(false)
	else:
		get_tree().current_scene.get_node("Interface").get_node("PauseScreen").set_process_input(true)
		
		# // {		# Another way to take away the inputs control from the other pause node	(DEPRECATED)
		#if (event.is_action_pressed("ui_pause")):
		#	print("on pause_screen, PauseScreen was called")
		#	accept_event()		# Marks an input event as handled. Once you accept an input event, it stops propagating
		# // }		# Another way to take away the inputs control from the other pause node	(DEPRECATED)
		
	if (event.is_action_pressed("Pause")):		# temp is letter "O", this will sibstitute my "PauseScene.tscn"	
		is_pause_screen_called = true
		get_tree().paused = !get_tree().paused
		
		if (get_tree().paused == false):
			print(String(get_tree().paused) + ", pause state is false!")
			continue_game()
			is_pause_screen_called = false
		else:
			print(String(get_tree().paused) + ", pause state is true!")
			go_to_menu_screen()
			print("on pause_screen, I'm handle inputs now, no PauseScreen hey for now!!!!!!!!!!!!!!!!!!!!!!!")
			accept_event()

func continue_game():
	print("on Pause_Screen, func exit_PauseScreen_continue_game() was called.............!")
	get_tree().paused = false
	
	get_parent().set_layer(-1)
	set_visible(false)
	continue_button.disabled = true
	open_levels_access_button.disabled = true
	$Levels_Teleport.set_layer(-1)
	level_teleport_window.visible = false
	levels_popup_menu.visible = false

func go_to_menu_screen():
	print("on Pause_Screen, func back_to_menu_screen() was called.............!")
	print("on Pause_Screen, continue_button.is_processing_input(): " + str(is_processing_unhandled_input()))
	get_tree().paused = true
	set_process_unhandled_input(true)
	
	if(!continue_button.is_processing_input()):
		print("on Pause_Screen, input is not processed!!!!!!")
		print(is_processing())
	
	get_parent().set_layer(99)
	set_visible(true)
	continue_button.disabled = false
	open_levels_access_button.disabled = false
	$Levels_Teleport.set_layer(-1)
	level_teleport_window.visible = false
	levels_popup_menu.visible = false

func _on_Continue_button_pressed():
	continue_game()

func _on_Open_levels_access_pressed():
	print("on Pause_Screen, Openning levels teleportation's screen!!")
	get_parent().set_layer(-1)
	set_visible(false)
	continue_button.disabled = true
	open_levels_access_button.disabled = true
	$Levels_Teleport.set_layer(99)
	level_teleport_window.visible = true
	levels_popup_menu.visible = true

func _on_PopupMenu_id_pressed(id):
	var getId = String(id)
	print("on Pause_Screen, PopupMenu id: " + getId)
	
	match id:
		0:
			print("on Pause_Screen, PopupMenu, item pressed is Level_1")
			continue_game()
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene("res://Particles_playground/Level_01.tscn", Vector2(1054, 372), -1)
		1:
			print("on Pause_Screen, PopupMenu, item pressed is Level_2")
			continue_game()
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene("res://Particles_playground/Level_02.tscn", Vector2(1198, 436), -1)
		2:
			print("on Pause_Screen, PopupMenu, item pressed is Level_3")
			continue_game()
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene("res://Particles_playground/Level_03.tscn", Vector2(1388, 372), -1)
		3:
			print("on Pause_Screen, PopupMenu, id is 3 or other else!!!!")
			go_to_menu_screen()
	
	return null
	print("on Pause_Screen, Outside match id, return null???")
