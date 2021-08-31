extends Area2D

signal from_parent_to_particle_should_emitting_signal(should_emitting)

export(String, FILE) var next_scene_path = ""
export(Vector2) var spawn_location = Vector2(0, 0)
export(int) var spawn_direction = 1

# if true Player can't pass through (if need to be unlocked, this should be true, because if false is free to go)
export(bool) var is_locked = false

func _ready():
	print("Skull_Portal is ready!!")
	print(next_scene_path)
	emit_signal("from_parent_to_particle_should_emitting_signal", !is_locked)

func _process(delta):
	# Show that is possible to access the variable "emitting" of the particles, so I can emitting It when It's convenient like when the Skull_Portal is unlocked and player can pass!
	# // {
	if (Input.is_action_just_pressed("ui_select")):
		is_locked = !is_locked
		emit_signal("from_parent_to_particle_should_emitting_signal", !is_locked)
		print("Input here on Skull_Portal, is_locked: " + String(is_locked))
	# // }
#	pass

func _on_Skull_Portal_body_entered(body):
	if (body.name == "Player_mult_FSM" and is_locked == false):
		#print("body entered, body is: " + String(body.name))	# return "Player_mult_FSM"
		if (next_scene_path == null or next_scene_path == ""):
			print("ERROR: next_scene_path is null or a empty string")
			print(next_scene_path)
		else:
			var scene_manager = get_tree().current_scene
			scene_manager.transition_to_scene(next_scene_path, spawn_location, spawn_direction)
			print("on Skull_Portal, func body_entered(), next_scene_path: " + String(next_scene_path))

