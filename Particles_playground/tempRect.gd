extends KinematicBody2D

# To test velocity and collision with "is_on_floor()" method

const UP = Vector2(0, -1)
const vel = 32 * 0.04

var speed = Vector2.ZERO

var is_grounded = false

func _ready():
	print("tempRect is ready")
	print("on tempRect.pos: " + str(position))

func _physics_process(delta):
	speed.y += (Globals.UNIT_SIZE * 9.2) * delta
	
	if (is_on_floor()):
		print("on tempRect, NOT on floor!")
		speed = Vector2.ZERO
	
	var stop_on_slop = true if get_floor_velocity().x == 0 else false
	
	move_and_slide(speed, UP, stop_on_slop)
	
	if(Input.is_action_just_pressed("ui_down")):
		print("on tempRect, arrow down was clicked, temp debug, teleport me!")
		position = Vector2(2076, 300 - 200)


func _on_Area2D_body_entered(body):
	#print("on tempRect, area entered, body.name: " + str(body.name))
	#is_grounded = true
	#speed = 0
	pass


func _on_Area2D_body_exited(body):
	#print("on tempRect, area exited, body.name: " + str(body.name))
	#is_grounded = false
	#speed = vel
	pass
	
