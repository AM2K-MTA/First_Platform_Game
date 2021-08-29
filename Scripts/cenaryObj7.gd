extends StaticBody2D

const SPEED = 150
var motion = Vector2()

func _physics_process(delta):
	#print(position.y)
	# min 360  max 504
	
	if position.y <= 504:
		position.y += SPEED
	#if position.y <= 360:
	#	position.y += SPEED
		
	# temp to debug the game (reset position of player to almost the center of screen)
	if Input.is_key_pressed(KEY_SPACE):
		position.x = 416
		position.y = 360
