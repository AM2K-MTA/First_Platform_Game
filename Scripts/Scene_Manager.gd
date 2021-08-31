extends Node2D

var next_scene = null

var player_location := Vector2(0, 0)
var player_direction : int = 1

enum TransitionType { NEW_SCENE, PARTY_SCREEN, MENU_ONLY }
var transition_type = TransitionType.NEW_SCENE

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Scene_Manager is ready!!")

func transition_to_party_screen():
	print("on Scene_Manager, func transition_to_party_screen() was called")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.PARTY_SCREEN

func transition_exit_party_screen():
	print("on Scene_Manager, func transition_exit_party_screen() was called")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.MENU_ONLY

func transition_to_scene(new_scene: String, spawn_location: Vector2, spawn_direction: int):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = TransitionType.NEW_SCENE
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")

func finished_fading():
	match transition_type:
		TransitionType.NEW_SCENE:
			print("on Scene_Manager, func finishing_fading(), called after anim FadeToBlack was finished")
			#print(player_location)
			$Current_Scene.get_child(0).queue_free()
			$Current_Scene.add_child(load(next_scene).instance())
			
			var player = get_node("Player_mult_FSM")
			player.set_spawn(player_location, player_direction)
			#print(player_location)
		TransitionType.PARTY_SCREEN:
			#$Menu.load_party_screen()
			pass
		TransitionType.MENU_ONLY:
			#$Menu.unload_party_screen()
			pass

	$ScreenTransition/AnimationPlayer.play("FadeToNormal")
