class_name Golem
extends KinematicBody2D

onready var states_container = $States
onready var core_SM = $States/Core_SM_Golem
onready var action_SM = $States/Action_SM_Golem

onready var anim_player = $AnimationPlayer

onready var raycasts = $Raycasts
onready var rc_wall_detector = $WallDetectorFront
onready var sprite = $Sprite

const GRAVITY = 32
const UP = Vector2.UP

var movement = Vector2()
var speed = 100
var moving_left = true

var is_dead = false
var is_grounded = false
var is_falling = false
var is_dragged_by_movable_obj = false

var raycasts_collider = null

func _ready():
	print("Golem is ready!!")
	#pass

func _apply_gravity(delta):
	movement.y += GRAVITY * delta

func _apply_movement():
	#print("movement.x is: " + str(movement.x))
	
	movement.y += GRAVITY
	
	movement.x = -speed if moving_left else speed
	
	movement = move_and_slide(movement, UP)
	
	is_grounded = !is_falling && _check_is_grounded()
	
	if (rc_wall_detector.is_colliding()):
		moving_left = !moving_left
		#print("moving_left is: " + str(moving_left))
		rc_wall_detector.scale.x = -rc_wall_detector.scale.x
	
	if (moving_left):
		# The sprite of Golem by default is "golem walk to the left", so It's scale.x = 1, if turn right is scale.x = -1
		sprite.scale.x = 1
	elif (!moving_left):
		sprite.scale.x = -1
	
	#if (anim_player.is_playing()):
	#	print("on Golem, get anim name: " + str(anim_player.current_animation.get_basename()))
		
func _check_is_grounded():
	#print("On Golem, func _check_is_grounded() was called!!")
	for raycast in raycasts.get_children():
		if (raycast.is_colliding()):
			#print("on player._check_is_grounded(), raycast collided: " + String(raycast.name))		# that never happens, WHY IS NEVER TRUE and detect some collision??
			raycasts_collider = raycast.get_collider()
			#print("On Golem, collider.name: " + str(raycasts))
	#		if (raycast.name == "WallDetectorFront"):
	#			#print("On Golem, raycast WallDetectorFront is colliding!!")
	#			moving_left = !moving_left
	#			raycast.scale.x = -raycast.scale.x
	#			sprite.scale.x = -sprite.scale.x
			if (raycast.name == "MovingPlatform"):		# Fix a player's bug (player alternate between "state.idle and state.fall")
				#print("Player is NOT moving, but is on a movable obj!!")
				is_dragged_by_movable_obj = true
			
			return true
		else:
			is_dragged_by_movable_obj = false
	
	# If loop completes then raycast was not detected
	#print("on player, loop completed and no raycasts collision detect")
	raycasts_collider = null
	return false

func _pre_die():
	print("on Golem, func _pre_die()!")
	core_SM._die()

func _pre_explode():
	#make sure nothing collides against this
	#$Shape.queue_free()
	
	$HitBox_L/CollisionShape2D.queue_free()
	$HitBox_R/CollisionShape2D.queue_free()
	$HurtBox/CollisionShape2D.queue_free()
	
	print("on Golem, func _pre_explode(), all collisionShape was queue_free()!")

func remove():
	# mod to delete when It was Hit
	_pre_explode()
	yield(get_tree().create_timer(0.5), "timeout")
	_pre_die()
#	queue_free()

func _on_HitBox_L_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Golem, player entered on HitBox_L area!!")
		(body as KinematicBody2D).was_hitted_side = -1
	elif (body.name == "Throw_atk_Punch"):
		print("on Golem, Throw_atk_Punch.tscn entered on HitBox_L area!!")
		is_dead = true

func _on_HitBox_R_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Golem, player entered on HitBox_R area!!")
		(body as KinematicBody2D).was_hitted_side = 1
	elif (body.name == "Throw_atk_Punch"):
		print("on Golem, Throw_atk_Punch.tscn entered on HitBox_R area!!")
		is_dead = true

func _on_HurtBox_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Golem, player entered on HurtBox area!!")
		is_dead = true
