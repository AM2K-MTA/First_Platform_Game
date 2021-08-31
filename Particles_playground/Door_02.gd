extends Area2D

export(String, FILE) var next_scene_path = ""
export(Vector2) var spawn_location = Vector2(0, 0)
export(int) var spawn_direction = 1

# if true Player can't pass through (if the need to be unlocked, this should be true, because if false is free to go)
export(bool) var is_locked = false

func _ready():
	print("Door_02 is ready!!")
	print(next_scene_path)

func _process(delta):
	# Show that is possible to access the variable "emitting" of the particles, so I can emitting It when It's convenient like when the Door_02 is unlocked and player can pass!
	# // {
	#if (Input.is_action_pressed("ui_select")):
	#	$Fire_effect_01/Particles2D.emitting = !$Fire_effect_01/Particles2D.emitting
	#	print("on Door_02, func process(), get player pos to fix spawn position on Level_02")
	#	print(get_tree().current_scene.get_node("Player_mult_FSM").position)
	
	#if (is_locked):
	#	$Fire_effect_01/Particles2D.emitting == false
	#else:
	#	$Fire_effect_01/Particles2D.emitting == true
	#
	#if (Input.is_action_pressed("ui_select")):
	#	is_locked = !is_locked
	#	
	#print("is_locked: " + String(is_locked))
	

	#if ($Fire_effect_01/Particles2D.emitting == false):
	#	is_locked = true
	#else:
	#	is_locked = false
	# // }
	pass

func _on_Door_02_body_entered(body):
	if (body.name == "Player_mult_FSM" and is_locked == false):
		#print("body entered, body is: " + String(body.name))	# return "Player_mult_FSM"
		# transition to other scene
		#SceneChanger.change_scene("res://Particles_playground/Level_01.tscn")		# Original code
		#SceneChanger.change_scene("res://Particles_playground/Level_02.tscn")		# mod to alterate TileMap
		if (next_scene_path == null or next_scene_path == ""):
			print("ERROR: next_scene_path is null or a empty string")
			print(next_scene_path)
		else:
			#var current_scene = get_tree().current_scene.get_node("Current_Scene")
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene(next_scene_path, spawn_location, spawn_direction)
			print("on Door_02, func body_entered(), next_scene_path: " + String(next_scene_path))
