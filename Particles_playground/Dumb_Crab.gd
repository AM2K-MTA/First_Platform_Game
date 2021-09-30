class_name Dumb_Crab
extends KinematicBody2D

# base code tutorial's link: https://youtu.be/KXsVXH6055M

onready var states_container = $States
onready var core_SM = $States/Core_SM_Dumb_Crab
onready var action_SM = $States/Action_SM_Dumb_Crab

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
	#print("Dumb_Crab is ready!!")
	pass

func _apply_gravity(delta):
	movement.y += GRAVITY * delta

func _apply_movement():
	movement.y += GRAVITY
	
	movement.x = -speed if moving_left else speed
	
	movement = move_and_slide(movement, UP)
	
	is_grounded = !is_falling && _check_is_grounded()
	
	if (rc_wall_detector.is_colliding()):
		moving_left = !moving_left
		rc_wall_detector.scale.x = -rc_wall_detector.scale.x
		sprite.scale.x = -sprite.scale.x
	
	#if (anim_player.is_playing()):
	#	print("on dumb_Crab, get anim name: " + str(anim_player.current_animation.get_basename()))
		
func _check_is_grounded():
	#print("On Dumb_Crab, func _check_is_grounded() was called!!")
	for raycast in raycasts.get_children():
		if (raycast.is_colliding()):
			#print("on player._check_is_grounded(), raycast collided: " + String(raycast.name))		# that never happens, WHY IS NEVER TRUE and detect some collision??
			raycasts_collider = raycast.get_collider()
			#print("On Dumb_Crab, collider.name: " + str(raycasts))
	#		if (raycast.name == "WallDetectorFront"):
	#			#print("On Dumb_Crab, raycast WallDetectorFront is colliding!!")
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
	print("on Dumb_Crab, func _pre_die()!")
	core_SM._die()

func _pre_explode():
	#make sure nothing collides against this
	#$Shape.queue_free()
	
	$HitBox_L/CollisionShape2D.queue_free()
	$HitBox_R/CollisionShape2D.queue_free()
	$HurtBox/CollisionShape2D.queue_free()
	
	print("on Dumb_Crab, func _pre_explode(), all collisionShape was queue_free()!")

func _on_HitBox_L_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Dumb_Crab, player entered on HitBox_L area!!")
		(body as KinematicBody2D).was_hitted_side = -1

func _on_HitBox_R_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Dumb_Crab, player entered on HitBox_R area!!")
		(body as KinematicBody2D).was_hitted_side = 1

func _on_HurtBox_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Dumb_Crab, player entered on HurtBox area!!")
		is_dead = true
