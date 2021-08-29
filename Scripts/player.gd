extends KinematicBody2D

# The "cenaryObj19" is on y position = 478 is reached by player's jump, but on y position = 477, player doesn't reached (alcança)
# jump 135px vertical jump, and jump from 730 to 910 = 180px horizontal jump

# jump: velocity.y = 0, jump input received --> velocity.y = -450 (value gradativelly drop to -13, -14 or 0.000X and start to fall) --> velocity.y = 0, velocity.y += X (value will be gradativelly incremented positivelly until touch the ground)
# Soo, put the animation transition in some point between -50/-13, because the player is almost on max_jump_height, and in this point the fall animation start, and the strange transition happens (jump animation and fall animation)

signal grounded_updated(is_grounded)

#const FloatingText_PS = preload("res://FloatingText.tscn")
const RockProjectile_PS = preload("res://Hand_FistProjectile.tscn")

const UP = Vector2(0, -1)
const SLOP_STOP = 64		# what is that for ??!
const DROP_THRU_BIT = 1

var velocity = Vector2()	# max_vel = 479.7 ou 479.7 (left and right side change just the negative sign to the left, left_max_vel = -479.5)
var move_speed = 5 * Globals.UNIT_SIZE		# = 5 * Globals.UNIT_SIZE or = 5 * 35
var gravity
var max_jump_velocity
var min_jump_velocity

var held_item = null

var is_jumping = false
var is_grounded = false

var throwing_rock = false

var max_jump_height = 2.25 * 50		# = 2.25 * Globals.UNIT_SIZE (UNIT_SIZE = 96)
var min_jump_height = 0.8 * 50	# = 0.8 * Globals.UNIT_SIZE
var jump_duration = 0.5		# = 0.5		(0.8 fica quase uma queda com para-quedas)

var facing

onready var raycasts = $Raycasts	# Do I need this here ??!

onready var anim_player = $Body/CharacterRig/AnimationPlayer
onready var drop_thru_raycasts = $DropThruRayCasts
onready var body = $Body
onready var held_item_position = $Body/PlayerRig/Torso/RightArm/HeldItemPosition
onready var hitbox = $Hitbox

var countNum : int = 1

func _ready():
	# trocar o "gravity = 2 * ..." por "gravity = _get_h_weight() * ...", makes a nice effect of slow motion with gradative fall on diagonals down, like The Matrix game (voadora up, down + attack)
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	#print("gravity: " + String(gravity))					# 900
	#print("max_jump_height: " + String(max_jump_height))	# 112.5
	#print("min_jump_height: " + String(min_jump_height))	# 40

func _apply_gravity(delta):
	# apply gravity.
	velocity.y += gravity * delta
	
func _apply_movement():
	#print("_apply_movement() was called!")
	# set is_jumping to false if player is jumping and moving downward.
	if (is_jumping && velocity.y >= 0):
		is_jumping = false
	
	velocity = move_and_slide(velocity, UP, SLOP_STOP)
	
	# check reycasts to see if player is grounded, but just if they're not jumping and not falling through platform.
	is_grounded = !is_jumping && get_collision_mask_bit(DROP_THRU_BIT) && _check_is_grounded()

func _handle_move_input():
	if (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
		#print(-int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right")))
		#print(-int(Input.is_action_pressed("ui_right")))
		# "Input.get_action_strength("ui_left")" return 1 if that Key was pressed or 0 if other is pressed
	
		#countNum += 1
		#print("_handle_move_input() was called!, " + String(countNum))
		# Get movement KeyPresses, converts to integers, and then store in move_direction.
		var move_direction = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
		# Lerp velocity.x towards the direction the player is pressing keys for, weighted based on if they're grounded or not.
		velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
		#print("velocity.x: " + String(velocity.x))
		#print("move_speed: " + String(move_speed))
		# Set sprite facing based on the last (movement) key pressed.
		if (move_direction != 0):
			$Body.scale.x = move_direction
			
			#countNum += 1
			#print("_handle_move_input() was called!, " + String(countNum))
			# mod (DirectionInput_rayCast) next 6 lines
			facing = move_direction
			var inputDir_cast = $DirectionInput_rayCast
			inputDir_cast.cast_to = Vector2(50 * facing, 0)
			inputDir_cast.force_raycast_update()
			if (inputDir_cast.is_colliding()):
				print(String(inputDir_cast.get_collider().name) + " is in front of me")
	elif (velocity.x != 0):	# era um else, not elif.
		#var on_else = countNum
		#var on_else_if = 0
		#var on_else_else = 0
		#print("-------------------------------------- else: " + String(on_else))
		
		while (velocity.x != 0):
			if (velocity.x < 0 and velocity.x >= -16 or velocity.x >= 0.001 and velocity.x <= 16):
				velocity.x = 0
			
				#on_else_if += 1
				#print("----------- on gap, set_velocity_x(0) --------- else_if: " + String(on_else_if))
			else:
				velocity.x = lerp(velocity.x, 0, _get_h_weight())
					
				#on_else_else += 1
				#print("------------------ lerp ------------- else_else: " + String(on_else_else))
		#print("------------------- outside of while loop -------------------------")
	else:
		# if "_handle_move_input()" has more code, this code should continue here, and maybe I could add other "elif" before this else, right?!
		#print("Here're go the rest of _handle_move_input() code! Velocity.x: " + String(velocity.x))
		pass
		
func _get_h_weight():
	return 0.2 if is_grounded else 0.1		# What is that for (if chenge the value 0.1 to "else 2.5"), something realy creazy happens, WTF ??!

func _check_is_grounded():
	for raycast in raycasts.get_children():
		if (raycast.is_colliding()):
			#print("raycast collided: " + String(raycast.name))		# that never happens, WHY IS NEVER TRUE and detect some collision??
			return true
	
	# If loop completes then raycast was not detected
	return false

# Not needed anymore, was replaced by StateMachine or PlayerFSM
#func _assign_animation():
#	pass

func spawn_rock():
	if (held_item == null):
		held_item = RockProjectile_PS.instance()
		held_item_position = add_child(held_item)

func _throw_held_item():
	held_item.launch(facing)
	held_item = null
	#throwing_rock = false
