class_name Player
extends KinematicBody2D

# The "cenaryObj19" is on y position = 478 is reached by player's jump, but on y position = 477, player doesn't reached (alcança)
# jump 135px vertical jump, and jump from 730 to 910 = 180px horizontal jump

# jump: velocity.y = 0, jump input received --> velocity.y = -450 (value gradativelly drop to -13, -14 or 0.000X and start to fall) --> velocity.y = 0, velocity.y += X (value will be gradativelly incremented positivelly until touch the ground)
# Soo, put the animation transition in some point between -50/-13, because the player is almost on max_jump_height, and in this point the fall animation start, and the strange transition happens (jump animation and fall animation)

# Note "Level_01" tilemap size is aproximally (width: 2248, height: 896)

signal grounded_updated(is_grounded)

#const FloatingText_PS = preload("res://FloatingText.tscn")
const RockProjectile_PS = preload("res://Scenes/Hand_FistProjectile.tscn")

# // { referent to mod "Throw_atk_Punch.tscn", It's a simple attack that'll be used to create hit combos
const throw_atk_punch = preload("res://Particles_playground/Throw_atk_Punch.tscn")
var can_fire_atk_punch = true
var rate_of_fire_atk_punch = 0.4
# // }  referent to mod "Throw_atk_Punch.tscn", It's a simple attack that'll be used to create hit combos

const UP = Vector2(0, -1)
const SLOP_STOP_THRESHOLD = 64.0		# Something like help player don't slide out of a platform or slide awkward (google "Slop stop" to undestand better)
const DROP_THRU_BIT = 2
const DROP_THRU_BIT_7 = 7

var move_direction
var velocity = Vector2()	# max_vel = 479.7 ou 479.7 (left and right side change just the negative sign to the left, left_max_vel = -479.5)
var move_speed = 5.25 * Globals.UNIT_SIZE		# = 5 * Globals.UNIT_SIZE or = 5 * 32
var gravity
var max_jump_velocity
var min_jump_velocity

var held_item = null

var is_jumping = false
var is_grounded = false

var throwing_rock = false
var end_throw_anim_bool = false

# max-jump = 2.25 * 50 = 112.5		3.25 * 32 = 104
var max_jump_height = 3.25 * Globals.UNIT_SIZE		# = 2.25 * Globals.UNIT_SIZE (UNIT_SIZE = 96)... But I put (2.25 * 50)
var min_jump_height = 0.8 * Globals.UNIT_SIZE		# = 0.8 * Globals.UNIT_SIZE... But I put (0.8 * 32)
var jump_duration = 0.5		# = 0.5		(0.8 fica quase uma queda com para-quedas)

onready var raycasts = $Raycasts

var facing = 1
onready var states_container = $States
onready var core_SM = $States/Core_SM_PlayerFSM
onready var action_SM = $States/Action_SM_PlayerFSM

onready var anim_player = $Body/CharacterRig/AnimationPlayer
onready var drop_thru_raycasts = $DropThruRayCasts
onready var body = $Body
onready var held_item_position = $Body/CharacterRig/Torso/RightArm/HeldItemPosition
#onready var hitbox = $Hitbox

# // {	mod animation "atk_simple_punch_1st"
onready var anim_player_not_core = $Body/CharacterRig/AnimationPlayer_not_core_anim
onready var timer_atack = $Body/CharacterRig/Timer_Attack
var is_attacking_simple_atk = false
var can_turn_around = true		# If true and Input receive that make player turn, he turn ELSE he stay facing the same direction
# // }	mod animation "atk_simple_punch_1st"

var countNum : int = 1

var donut = preload("res://Scenes/Donuts.tscn")
onready var throw_hand_pos = $Body/CharacterRig/Torso/RightArm/HeldItemPosition
var can_throw_donut := false	# change to "was_donuts_thrown := false" (because when I throw It on "Core_SM_PlayerFSM", this variable will change to "was_donuts_thrown = true")
var can_throw_hand := false

var has_knife := false	# mod (new throwable item) --> If I have the knife, this is true
# this will differenciate the knife before I pick It at the first time, to when I pick after dispose It or throw It, because if I dispose or pick at first time should be different from when I Throw It (when It's pickable I could put the knife as a sprite on the game, ...
#   ...but when I throw It, I should render the knife as a complex obj that was throw and is fincada in other obj)
var was_knife_thrown := false	# mod (new throwable item) --> If I throw this knife I loose It ("has_knife = false"), I can't throw It again, but I can collect It again, so "has_knife" will be true again and this var will be false too

var is_dragged_by_movable_obj = false

signal player_drop_require_signal		# mod Fix_Platform
var raycasts_collider = null			# mod Fix_Platform

# // { mod Crab_Walker
export var knockback = 7000
export var knockup = 1000/2
var was_hitted_side = null
# // } mod Crab_Walker

func _ready():
	# trocar o "gravity = 2 * ..." por "gravity = _get_h_weight() * ...", makes a nice effect of slow motion with gradative fall on diagonals down, like The Matrix game (voadora up, down + attack)
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	#print("gravity: " + String(gravity))					# 900
	#print("max_jump_height: " + String(max_jump_height))	# 112.5
	#print("min_jump_height: " + String(min_jump_height))	# 40

func _apply_gravity(delta):
	#print("on player, func _apply_gravity(delta)...")		# It's called on infinite loop
	# apply gravity.
	velocity.y += gravity * delta

# link to Game Endeavor on exemplo of "_apply_movement()" atualized, link: https://youtu.be/eQeFE8LMjxA?t=96
func _apply_movement():
	#print("on player, func _apply_movement() was called!")		# It's called on infinite loop
	# set is_jumping to false if player is jumping and moving downward.
	if (is_jumping && velocity.y >= 0):
		is_jumping = false
	
	var snap = Vector2.DOWN * 32 if !is_jumping else Vector2.ZERO
	
	if (move_direction == 0 && abs(velocity.x) < SLOP_STOP_THRESHOLD):
		velocity.x = 0
	
	# // { Mod19mar22 1/2 to fix bug of player running without the run animation, It's running with "idle" animation
	# Make player stop moving to throw a object
	if (action_SM.state == 1):	# action_SM.state = 1 = state "throw_fist" 
#		print("core_SM: " + str(core_SM.state))
#		print("action_SM: " + str(action_SM.state))
		velocity.x = 0
	# // }
#	print("can_throw_hand: " + str(can_throw_hand))
	
	var stop_on_slop = true if get_floor_velocity().x == 0 else false
	
	velocity = move_and_slide_with_snap(velocity, snap, UP, stop_on_slop)
	
	# check reycasts to see if player is grounded, but just if they're not jumping and not falling through platform.
	is_grounded = !is_jumping && get_collision_mask_bit(DROP_THRU_BIT) && _check_is_grounded()
	
	_check_is_grounded2(drop_thru_raycasts)		# Check if player is colliding with a "Drop_Thru" layer, and fix a player's bug (more detail on func "_check_is_collided2()"
	
	# made on tutorial "create a FallingPlatform_GE from Game Endeavor"
	for i in get_slide_count():
		#print("on player's func _apply_movement(), for loop check method get_slide_count()")
		var collision = get_slide_collision(i)
		if (collision.collider.has_method("collide_with")):		# prevent errors
			#print("on player's func _apply_movement(), check if collider has a specific method")
			collision.collider.collide_with(collision, self)

func _handle_move_input():
	if (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):		# return "-1" input left, "1" input right or "0" both was pressed at same time, player don't move
		#print("on player, prosition: " + String(position))
		#print(-int(Input.is_action_pressed("ui_right")))
		# "Input.get_action_strength("ui_left")" return 1 if that Key was pressed or 0 if other is pressed

		var previous_move_dir = move_direction
		
		#countNum += 1
		#print("_handle_move_input() was called!, " + String(countNum))
		# Get movement KeyPresses, converts to integers, and then store in move_direction.
		move_direction = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
		
		if (can_turn_around):
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
				var raycast_look_door = $RayCast_Look_Door
				raycast_look_door.cast_to = Vector2(50 * facing, 0)
				raycast_look_door.force_raycast_update()
				if (raycast_look_door.is_colliding()):
					print(String(raycast_look_door.get_collider().name) + " is in front of me")
				
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

func print_state_onScreem():
	var coreState = null
	var actionState = null
	if (core_SM.state == 0):
		coreState = "idle"
	elif (core_SM.state == 1):
		coreState = "run"
	elif (core_SM.state == 2):
		coreState = "jump"
	elif (core_SM.state == 3):
		coreState = "fall"
	else:
		coreState = "unknown"
	
	if (action_SM.state == 0):
		actionState = "none"
	elif (action_SM.state == 1):
		actionState = "throw_fist"
	else:
		actionState = "unknown"

	#print("core_SM.state: " + String(coreState))
	#print("action_SM.state: " + String(actionState))

func set_spawn(location: Vector2, direction: int):
	#anim_tree.set("parameters/Idle/blend_position", direction)
	$Body.scale.x = direction
	#print(direction)
	position = location
	#set_position(location)

func _get_h_weight():
	return 0.2 if is_grounded else 0.1		# What is that for (if chenge the value 0.1 to "else 2.5"), something realy creazy happens, WTF ??!

func _check_is_grounded():
	for raycast in raycasts.get_children():
		if (raycast.is_colliding()):
			#print("on player._check_is_grounded(), raycast collided: " + String(raycast.name))		# that never happens, WHY IS NEVER TRUE and detect some collision??
			raycasts_collider = raycast.get_collider()
			return true
	
	# If loop completes then raycast was not detected
	#print("on player, loop completed and no raycasts collision detect")
	raycasts_collider = null
	return false

func _check_is_grounded2(raycast_container):
	for raycast2 in raycast_container.get_children():
		if (raycast2.is_colliding()):
			#print("on player._check_is_grounded2(), raycast collided: " + String(raycast2.name))		# that never happens, WHY IS NEVER TRUE and detect some collision??
			var body = raycast2.get_collider()
			#print("on player, func _check_is_grounded2()... body.name : " + String(body.name))
			
			if (body.name == "MovingPlatform"):		# Fix a player's bug (player alternate between "state.idle and state.fall")
				#print("Player is NOT moving, but is on a movable obj!!")
				is_dragged_by_movable_obj = true
			
			return true
		else:
			is_dragged_by_movable_obj = false
	
	# If loop completes then raycast was not detected
	return false

# Not needed anymore, was replaced by StateMachine or PlayerFSM
#func _assign_animation():
#	pass

func spawn_rock():
	if (held_item == null):
		held_item = RockProjectile_PS.instance()
		held_item_position = add_child(held_item)
		#can_throw_hand = false
	
		print("On player, func spawn_rock(), player.pos: " + String(position))
		
func _throw_held_item():
	print("on player, func _throw_held_item(), get_parent: " + String(get_parent().name))
	var throw_pos = $Body/CharacterRig/Torso/RightArm/HeldItemPosition.position
	held_item.launch(facing)
	held_item = null
	
	can_throw_hand = false
	
	# // { Mod19mar22 2/2 to fix bug of player running without the run animation, It's running with "idle" animation
	end_throw_anim_bool = true
	print("__________ testing... ____________, on player_mult_FSM, _throw_held_item(), end throw animation")
	# // }
	
	#print("get_parent: " + String(get_parent().name))
	#velocity = Vector2.ZERO
	#throwing_rock = false

func _player_mult_FSM_end_throw_anim():
	end_throw_anim_bool = true
	print("end throw animation")

func _on_Player_mult_FSM_end_death_anim():
	print("dead!!!! RIP")
	#var sceneManager = get_node("res://world.tscn")
	#sceneManager.set_physics_process(false)

func _on_CharacterRig_Donuts_throw_signal():
	if (can_throw_donut):
		var new_donut = donut.instance()		# instanciate a pre-loaded scene "Donuts" saved on Player_mult_FSM
		new_donut.set_scale(Vector2(0.6, 0.6))
		new_donut.position = throw_hand_pos.global_position
		new_donut.facing_dir = facing	# mod (shoot_dir)
		get_tree().current_scene.add_child(new_donut)
		can_throw_donut = false

func _on_CharacterRig_end_throw_donut_anim_signal():
	print("core.state: " + String(core_SM.state))
	if (core_SM.state == 0):
		anim_player.play("idle")
	elif (core_SM.state == 1):
		anim_player.play("run")
	else:
		anim_player.play("death_forward")

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	print("on player, visibility notifier, ATTENTION.......... VIEWPORT_EXITED signal was called! Where is the player?????????")
	#var getPos = String(position.x) + ", " + String(position.y)
	#print("on player, visibility notifier, viewport_exited, player position: " + getPos)
	#position = Vector2(2204, 200)
	get_tree().quit()

# // { mod Crab_Walker
func _on_HurtBox_area_entered(area):
	if (area.is_in_group("HitBox")):
		var knock_side = knockback * -move_direction
		if (was_hitted_side != null):
			knock_side = knockback * was_hitted_side
			
		print("On player, area_entered, hit!")
		velocity.x -= lerp(velocity.x, knock_side, 0.5)
		velocity.y = lerp(0, -knockup, 0.6)
		velocity = move_and_slide(velocity, UP)
		blink()

func blink():
	body.visible = false
	yield(get_tree().create_timer(0.05), "timeout")
	body.visible = true
	yield(get_tree().create_timer(0.07), "timeout")
	body.visible = false
	yield(get_tree().create_timer(0.1), "timeout")
	body.visible = true
# // } mod Crab_Walker
