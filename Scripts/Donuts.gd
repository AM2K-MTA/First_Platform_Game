extends Area2D

# link to this tutorial part1: https://www.youtube.com/watch?v=xwdo7vefJkM&list=WL&index=1&t=399s
# link to this tutorial part2: https://www.youtube.com/watch?v=LEFQjKw2Zew
# 3:58 (show code example multiples Hitboxies as Area2d and one o HurtBox, they use Area2D_body_entered)
# 12:12 (show code example of func blinck(), that makes the sprite visibility alternate between true/false with a timer delay
# 12:18 (teach how to do health and die system)

var speed = 200 # = 300
var rotation_speed = 15
var movable = true

var facing_dir = 1	#mod (shoot_dir)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("Donut is ready!!")
	speed = 200	# = 300
	var rotation_speed = 15

func _physics_process(delta):
	if (movable):
		position.x += speed * facing_dir * delta		# original code: position.x += speed * delta
		#position.y += 0.2		# mod poor effect of gravity, should implement the same "THROW_VELOCITY" from "Hand_FistProjectile"
		#print("position.x: " + String(position.x))
		#rotate(deg2rad(15))	# original code (Just made the rotate effect on clockwise direction, It's work when Item was thrown to the right, not good to the left)
		if (facing_dir == 1):		# mod (make effect of spinning clockwise direction if player facing to the right)
			rotate(deg2rad(15))
		elif (facing_dir == -1):		# mod (make effect of spinning counterclockwise direction if player facing to the left)
			rotate(deg2rad(-15))

func _on_Donuts_body_entered(body):
	print("on_Donuts_body_entered")
	if (body.is_in_group("Scene_Platform")):
		#print("on Donuts, _on_Donuts_body_entered(body), group plat check, collision detect, body.name: " + String(body.name))
		speed = 0
		#position = body.global_position	# original code
		if (facing_dir == 1):
			position = Vector2(body.global_position.x - 3, position.y)		#mod, stop on the same height, but a little before the center of the Donuts (Donuts's position is centered)
		elif (facing_dir == -1):
			# body sz = 40... Scale 0.8, 40 * 0.8 = 32 + (I don't want the Donut's center on the body.x + width, so add 3px to move It to the left a little, the tip of Donuts on the right wall of "body")
			position = Vector2(body.global_position.x + 35, position.y)		#mod, stop on the same height, but a little before the center of the Donuts (Donuts's position is centered)
		rotation_speed = 0
		movable = false
		#remove()		# original code
		yield(get_tree().create_timer(2.5), "timeout")		# mod, It's not on enemy, so the Donut will stay on the Platform for a bit iNTENTION IS make some animation to make it desapears slowlly or something else
		queue_free()		# mod, for now, after "timeout", take out from tree()
	elif (body.is_in_group("Enemies")):
		#print("on Donuts, _on_Donuts_body_entered(body), group Enemy check, collision detect, body.name: " + String(body.name))
		body.remove()
		speed = 0
		position = body.global_position
		remove()
	else:
		print("on Donuts, _on_Donuts_body_entered(body), on else, body.name: " + String(body.name))

func remove():
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	#print("Oh no! I'm leaving the screen area")
	queue_free()
