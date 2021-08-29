class_name MovingPlatform3
extends Node2D

export var motion = Vector2()
export var cycle = 1.0

var accum = 0.0

func _physics_process(delta):
	#print("MovinvingPlatform is working!!")
	# If "motion.x or motion.y" = 50 (Platform on pos(200, 200), so this platform will move 50px to top, go back to original position and move 50px to bottom, or in total move 100px
	
	accum += delta * (1.0 / cycle) * TAU
	accum = fmod(accum, TAU)
	
	var d = sin(accum)
	var xf = Transform2D()
	
	xf[2] = motion * d
	($MovingPlatform as RigidBody2D).transform = xf
