extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Door_01 is ready!!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Door_01_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		#print("body entered, body is: " + String(body.name))	# return "Player_mult_FSM"
		# transition to other scene
		SceneChanger.change_scene("res://Particles_playground/Level_01.tscn")
