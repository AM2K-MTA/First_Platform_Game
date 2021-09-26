class_name Dumb_Crab
extends KinematicBody2D

signal grounded_updated(is_grounded)

onready var states_container = $States
onready var core_SM = $States/Core_SM_Dumb_Crab
onready var action_SM = $States/Action_SM_Dumb_Crab

onready var container_raycasts = $Container_Raycasts
onready var container_rc_check_below = $Container_Raycasts/Container_RC_Check_Below
onready var container_rc_check_above = $Container_Raycasts/Container_RC_Check_Above
onready var container_rc_check_sides = $Container_Raycasts/Container_RC_Check_Sides

onready var container_area2D = $Container_Areas2D
onready var container_a2d_tracking_player = $Container_Areas2D/Container_Tracking_Player
onready var container_a2d_tracking_player_track_above = $Container_Areas2D/Container_Tracking_Player/Area2D_Track_Above
onready var container_a2d_tracking_player_track_front = $Container_Areas2D/Container_Tracking_Player/Area2D_Track_Front
onready var container_a2d_hitbox = $Container_Areas2D/Container_HitBox
onready var container_a2d_hitbox_HitBox = $Container_Areas2D/Container_HitBox/Hitbox

onready var anim_player = $AnimationPlayer

# NOTE: if rayCast on "Container_RC_Check_Above" detect some obj's layer "World", he is upside down (What should I do if this happens, maybe animate him to turn back on his feet, right?)

enum State {
	WALKING,
	DYING,
}

var state = State.WALKING

var is_grounded = false
var is_dragged_by_movable_obj = false

const UP = Vector2(0, -1)
var velocity = Vector2()	# max_vel = 479.7 ou 479.7 (left and right side change just the negative sign to the left, left_max_vel = -479.5)
var move_speed = 5.25 * Globals.UNIT_SIZE		# = 5 * Globals.UNIT_SIZE or = 5 * 32
var gravity
var direction = -1
var anim = ""

var Bullet = preload("res://Scenes/Donuts.tscn")

func _ready():
	print("Dumb_Crab is ready!!")
	gravity = Globals.UNIT_SIZE * 0.3

func _apply_gravity(delta):
	#print("on player, func _apply_gravity(delta)...")		# It's called on infinite loop
	# apply gravity.
	velocity.y += gravity * delta

func _apply_movement():
	velocity.y += gravity
	
	if (is_on_floor()):
		print("on tempRect, NOT on floor!")
		velocity = Vector2.ZERO
	
	var stop_on_slop = true if get_floor_velocity().x == 0 else false
	
	move_and_slide(velocity, UP, stop_on_slop)
	
	if(Input.is_action_just_pressed("ui_down")):
		print("on Dumb_crab, arrow down was clicked, temp debug, teleport me!")
		position = Vector2(2176, 320 - 100)
		#print("on Dumb_crab, arrow down was clicked, pos: " + str(position))
	
func _check_is_grounded(raycast_container):
	for rc in raycast_container.get_children():
		if (rc.is_colliding()):
			#print("on Dumb_Crab._check_is_grounded2(), raycast collided: " + String(rc.name))		# that never happens, WHY IS NEVER TRUE and detect some collision??
			var body = rc.get_collider()
			print("on Dumb_Crab, func _check_is_grounded2()... body.name : " + String(body.name))
			
			if (body.name == "MovingPlatform"):		# Fix a player's bug (player alternate between "state.idle and state.fall")
				#print("Player is NOT moving, but is on a movable obj!!")
				is_dragged_by_movable_obj = true
			
			return true
		else:
			is_dragged_by_movable_obj = false
	
	# If loop completes then raycast was not detected
	return false

func _die():
	queue_free()

func _pre_explode():
	#make sure nothing collides against this
	$Shape.queue_free()
	
	# maybe do a for loop to get the children of the containers below the is type "CollisionShape2D" and them desabled or kill them with "queue_free()"
	#container_area2D.queue_free()
	#container_raycasts.queue_free()
	
	($SoundExplode as AudioStreamPlayer2D).play()

func _on_Area2D_Track_Above_body_entered(body):
	# Check for Player's collision, if happens set the code to "trample_by_player" (Could be like in Mario, enemy die, or something like a spike that attack the player)
	pass # Replace with function body.

func _on_Area2D_Track_Above_body_exited(body):
	# Player is not Trample me anymore, this is useful if player trample me don't result in my death, right?!
	pass # Replace with function body.

func _on_Area2D_Track_Front_body_entered(body):
	# If Player is colliding, start a ATTACK against him
	pass # Replace with function body.

func _on_Area2D_Track_Front_body_exited(body):
	# If Player is NOT colliding anymore, stop attack him, maybe start to seek him
	pass # Replace with function body.
