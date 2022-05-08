extends KinematicBody2D

# Link original turotial: https://youtu.be/tX9yzjigV1k

var rotation_speed = 2.0	# original code
var get_player	# original code

var btn = false

func _ready():
	get_player = get_tree().current_scene.find_node("Player_mult_FSM")		# original code

#func _input(event):
#	if(event is InputEventMouseButton and Input.is_mouse_button_pressed(1)):
#		btn = true

func _physics_process(delta):
#	rotateToTarget(get_player, delta)	# original code

#	if (btn):
#		spin(delta)
#		btn = false
	
	if (Input.is_mouse_button_pressed(1)):
		spin(delta)
		
func spin(delta):
#	print("mouse buutton 1 is pressed on pos: " + str(get_global_mouse_position()))
	var dir = get_global_mouse_position() - global_position
	var angTo = $Sprite.transform.x.angle_to(dir)
	$Sprite.rotate(sign(angTo) * min(delta * 2.0, abs(angTo)))

func rotateToTarget(target, delta):		# original code
	var direction = (target.global_position - global_position)
	var angleTo = $Sprite.transform.x.angle_to(direction)
	
	$Sprite.rotate(sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))
