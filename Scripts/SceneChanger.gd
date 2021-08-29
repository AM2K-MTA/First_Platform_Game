extends CanvasLayer

signal scene_changed_signal()

onready var animation_player = $AnimationPlayer
onready var black = $Control/Black

func change_scene(path, delay = 0.5):
	#print("on change_scene(), previous currentScene.name: " + String(get_tree().current_scene.name))
	
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("fade")
	yield(animation_player, "animation_finished")
	assert(get_tree().change_scene(path) == OK)
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed_signal")
	
	get_tree().current_scene.add_child(load("res://Scenes/Player_mult_FSM.tscn").instance())
	var player = get_tree().current_scene.get_node("Player_mult_FSM")
	player.set_position(Vector2(45, 245))
	player.set_scale(Vector2(0.5, 0.5))
	
	#print("on SceneChanger.change_scene(), new currentScene.name: " + String(get_tree().current_scene.name))
