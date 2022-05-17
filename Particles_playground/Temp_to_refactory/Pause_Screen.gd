extends Control

onready var continue_button = $CenterContainer/VBoxContainer/Continue_button
onready var open_levels_access_button = $CenterContainer/VBoxContainer/Open_levels_access_button

onready var level_teleport_window = $Levels_Teleport/Control
onready var levels_popup_menu = $Levels_Teleport/Control/CenterContainer/VBoxContainer/Popup/PopupMenu

var is_Pause_Screen_ACTIVE = false

func _ready():
	#print("______________________ Pause_Screen is ready!")
	get_parent().layer = 9
	
func _unhandled_input(event):
	#print("on Pause_Screen,			 _unhandled_input() receive Input!!")
	if (event.is_action_pressed("Pause")):		# temp is letter "O", this will sibstitute my "PauseScene.tscn"	
		#print("on Pause_Screen, key letter O was pressed")			# mod 9/10/21
		get_tree().set_input_as_handled()
		
		get_tree().paused = !get_tree().paused		# if true, _process() and _input and other is disabled
		is_Pause_Screen_ACTIVE = get_tree().paused
		#print("on Pause_Screen, is_Pause_Screen_ACTIVE: " + str(is_Pause_Screen_ACTIVE))
		
		if (!is_Pause_Screen_ACTIVE):
			exit_pause_screen()
		else:
			enter_pause_screen()
	
	#if (Input.is_key_pressed(KEY_2) and is_Pause_Screen_ACTIVE):	# for example purpose
	#	print("on Pause_Screen, is_Pause_Screen_ACTIVE, and key_2 was pressed!")

func _process(_delta):
	if (is_Pause_Screen_ACTIVE):
		#print("on Pause_Screen, process(), is Pause_Screen active: " + str(is_Pause_Screen_ACTIVE))
		get_tree().current_scene.get_node("Interface/PauseScreen").set_process_input(false)
	else:
		get_tree().current_scene.get_node("Interface/PauseScreen").set_process_input(true)
	
func enter_pause_screen():
	get_parent().layer = 9
	set_visible(true)
	continue_button.disabled = false
	open_levels_access_button.disabled = false
	$Levels_Teleport.set_layer(-1)
	level_teleport_window.visible = false
	levels_popup_menu.visible = false

func exit_pause_screen():
	get_parent().set_layer(-1)
	set_visible(false)
	continue_button.disabled = true
	open_levels_access_button.disabled = true
	$Levels_Teleport.set_layer(-1)
	level_teleport_window.visible = false
	levels_popup_menu.visible = false

func _on_Continue_button_pressed():
	get_tree().paused = false
	is_Pause_Screen_ACTIVE = get_tree().paused
	exit_pause_screen()

func _on_Open_levels_access_pressed():
	#print("on Pause_Screen, Openning levels teleportation's screen!!")
	get_parent().set_layer(-1)
	set_visible(false)
	continue_button.disabled = true
	open_levels_access_button.disabled = true
	$Levels_Teleport.set_layer(99)
	level_teleport_window.visible = true
	levels_popup_menu.visible = true

func _on_PopupMenu_id_pressed(id):
	#print("on Pause_Screen, PopupMenu id: " + str(id)
	match id:
		0:
			#print("on Pause_Screen, PopupMenu, item pressed is Level_1")
			exit_pause_screen()
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene("res://Particles_playground/Level_01.tscn", Vector2(1054, 372), -1)
			
			yield(get_tree().create_timer(0.8), "timeout")
			get_tree().paused = false
			is_Pause_Screen_ACTIVE = get_tree().paused
		1:
			#print("on Pause_Screen, PopupMenu, item pressed is Level_2")
			exit_pause_screen()
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene("res://Particles_playground/Level_02.tscn", Vector2(1198, 436), -1)
			
			yield(get_tree().create_timer(0.8), "timeout")
			get_tree().paused = false
			is_Pause_Screen_ACTIVE = get_tree().paused
		2:
			#print("on Pause_Screen, PopupMenu, item pressed is Level_3")
			exit_pause_screen()
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene("res://Particles_playground/Level_03.tscn", Vector2(1388, 372), -1)
			
			yield(get_tree().create_timer(0.8), "timeout")
			get_tree().paused = false
			is_Pause_Screen_ACTIVE = get_tree().paused
		3:
			#print("on Pause_Screen, PopupMenu, id is 3 or other else!!!!")
			enter_pause_screen()
	
	return null