extends Node2D

# I don't finish the GUI Tutorial, I stop on Title: "Prepare the bomb and emerald counters"
# Link to tutorial page: https://docs.godotengine.org/en/stable/getting_started/step_by_step/ui_game_user_interface.html
# Almost the as above, but on video and with some differences, link to the video Tutorial: https://youtu.be/y1E_y9AIqow

var next_scene = null

var player_location := Vector2(0, 0)
var player_direction : int = 1

enum TransitionType { NEW_SCENE, PARTY_SCREEN, MENU_ONLY }
var transition_type = TransitionType.NEW_SCENE

onready var player = get_node("Player_mult_FSM")

onready var gui = $CanvasLayer/GUI

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Scene_Manager is ready!!")
	#gui.set_position(Vector2(20, 20))

func transition_to_party_screen():
	#print("on Scene_Manager, func transition_to_party_screen() was called")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.PARTY_SCREEN

func transition_exit_party_screen():
	#print("on Scene_Manager, func transition_exit_party_screen() was called")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.MENU_ONLY

func transition_to_scene(new_scene: String, spawn_location: Vector2, spawn_direction: int):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = TransitionType.NEW_SCENE
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	
	if (player == null or player.name != "Player_mult_FSM"):
		player = get_node("Player_mult_FSM")
	
	var coreFSM = player.find_node("Core_SM_PlayerFSM")
	#print(coreFSM.name)
	#print(coreFSM.is_physics_processing())
	coreFSM.set_physics_process(false)
	# When player collide with portal, if his state is "states.run, states.fall" entre outros, he will freeze in that state and go to a new scene like that, so that reset to "states.idle"
	coreFSM.state = coreFSM.states.idle

func finished_fading():
	match transition_type:
		TransitionType.NEW_SCENE:
			#print("on Scene_Manager, func finishing_fading(), called after anim FadeToBlack was finished")
			$Current_Scene.get_child(0).queue_free()
			$Current_Scene.add_child(load(next_scene).instance())
			player.set_spawn(player_location, player_direction)
			#print(player_location)
		TransitionType.PARTY_SCREEN:
			#$Menu.load_party_screen()
			pass
		TransitionType.MENU_ONLY:
			#$Menu.unload_party_screen()
			pass

	$ScreenTransition/AnimationPlayer.play("FadeToNormal")

func finished_fading_normal():
	var coreFSM = player.find_node("Core_SM_PlayerFSM")
	
	if (coreFSM == null or coreFSM.name != "Core_SM_PlayerFSM"):
		#print("on Scene_Manager, player = null OR It's name is =! them real name")
		player = get_node("Player_mult_FSM")
		coreFSM = player.find_node("Core_SM_PlayerFSM")
		coreFSM.set_physics_process(true)
	else:
		if (!player.is_grounded):
			#print("on Scene_Manager, player is not grounded!!!")
			# if player is NOT grounded (in the air for example), he'll give a jump in the air, that make him enter on "states.fall" and fix that
			coreFSM.state = coreFSM.states.fall
		coreFSM.set_physics_process(true)
