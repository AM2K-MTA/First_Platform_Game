extends KinematicBody2D
class_name Player

# Deu ruim na direção q o player anda (up, down), tá ao contrário
# part2: https://www.youtube.com/watch?v=G0ZWNtx5_Xc
# part3: https://www.youtube.com/watch?v=wkNvqmAvtpo
# part4: https://www.youtube.com/watch?v=O5bD2mWiJzM  (não a parte das flores, animated sprites 9:20)
# part5: https://www.youtube.com/watch?v=__VTRQCV8k0&t=0s
# part6: https://www.youtube.com/watch?v=epGzdMMsprI
# part7: https://youtu.be/WOy8Dhe2ePE?t=1390
# part8: https://youtu.be/W6nhqt1ijgI?t=837
# part9: https://www.youtube.com/watch?v=UwkvvFtOyiQ

# https://youtu.be/RzUkBT7QwrU

signal player_moving_signal
signal player_stopped_signal

signal player_entering_door_signal
signal player_entered_door_signal

# mod LockedDoor
signal player_entering_lockedDoor_signal
signal player_entered_lockedDoor_signal

const LandingDustEffect = preload("res://LandingDustEffect.tscn")

export var walk_speed = 4.0
export var jump_speed = 4.0
const TILE_SIZE = 16

onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")
onready var ray = $BlockingRayCast2D
onready var ledge_ray = $LedgeRayCast2D
onready var door_ray = $DoorRayCast2D

# mod LockedDoor
onready var locked_door_ray = $LockedDoorRayCast2D

onready var shadow = $Shadow
var jumping_over_ledge: bool = false

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

# position of the player on the start position
var initial_position = Vector2(0, 0) setget, get_initial_pos
# each direction the player is moving
var input_direction = Vector2(0, 1)
var is_moving = false
var stop_input: bool = false
var percent_moved_to_next_tile = 0.0

#find_parent("CurrentScene")
onready var get_currentScene = self.get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.visible = true
	anim_tree.active = true
	initial_position = position
	shadow.visible = false
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	anim_tree.set("parameters/Turn/blend_position", input_direction)
	
	if (get_currentScene != null):
		print("currentScene: " + String(get_currentScene.name))
	
func set_spawn(location: Vector2, direction: Vector2):
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)
	anim_tree.set("parameters/Turn/blend_position", direction)
	position = location

func _physics_process(delta):
	if player_state == PlayerState.TURNING or stop_input:
		return
	elif is_moving == false:
		process_player_movement_input()
	elif input_direction != Vector2.ZERO:
		# call specific animation
		anim_state.travel("Walk")
		move(delta)
		
		#print("player.path: " + String(get_path()))	# /root/SceneManager/CurrentScene/TrainingRoom/Player
		#print("Player.position: " + String(position))
		#print("% to next tile: " + String(percent_moved_to_next_tile))
		#print("pos.x: " + String(initial_position.x + (input_direction.x * TILE_SIZE)))
		#print("pos.y: " + String(initial_position.y + (input_direction.y * TILE_SIZE)))  # initial_position + (16 or -16)
		#print("input_dir: " + String(input_direction))  # Vector2((0, 1) or (1, 0) or (0, -1) or (-1, 0)) or Vector2D.ZERO
		#print("delta: " + String(delta))	# return a const with type Float, mine It's: 0.016667
		
	else:
		# call specific animation
		anim_state.travel("Idle")
		is_moving = false

func get_initial_pos():
	# Player pos Vector2(0, 0) is wrong on "TrainingRoom", It's like on Js "translate(48, 64);", and here below I correct that
	var init_pos = Vector2(initial_position.x + 48, initial_position.y + 64)
	return init_pos

func process_player_movement_input():
	if input_direction.y == 0:
		# "Input.is_action_just_pressed" is make an action just one time each click... "Input.is_action_pressed" go on move
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
	else:
		anim_state.travel("Idle")
		
func need_to_turn():
	# if player press "left" (example) and his face direction is left = player move to left... Otherwise, player turn to the left
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
		
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func finished_turning():
	# I add a "Call Method Track" on "AnimationPlayer and add a key to call this function
	# Animation field - beside the timer, upside the key "sprite" and "player" on "+ add Track" - "Call Method Track" - click on "Player" and right click on the blue vertical line and insert the key to the func
	player_state = PlayerState.IDLE
	
func entered_door():
	if (locked_door_ray.is_colliding()):
		#print("entered_door() was called, Player entering on LokedDoor")
		emit_signal("player_entered_lockedDoor_signal")		# call a func from LokedDoor called close_door() that send the player to the right pos and map
	else:
		#print("entered_door() was called, Player entering a normal door")
		emit_signal("player_entered_door_signal")

func move(delta):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray.cast_to = desired_step
	ray.force_raycast_update()
	
	ledge_ray.cast_to = desired_step
	ledge_ray.force_raycast_update()

	door_ray.cast_to = desired_step
	door_ray.force_raycast_update()
	
	# mod LockedDoor
	locked_door_ray.cast_to = desired_step
	locked_door_ray.force_raycast_update()
	
	if door_ray.is_colliding():
		if percent_moved_to_next_tile == 0.0:
			emit_signal("player_entering_door_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			stop_input = true
			$AnimationPlayer.play("Desappear")
			$Camera2D.clear_current()
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	
	# mod LockedDoor (I have to check if the LockedDoor is open or not, to stop or go through)
	elif locked_door_ray.is_colliding():
		var colliderId = find_parent("CurrentScene").get_children().back().find_node("LokedDoor")
		
		if (colliderId.is_Open):
			#print("player could entering!")
			if (colliderId.choose_entering):
				# LokedDoor is connected with this signal and call enter_Door() on LokedDoor, but this func don't do anything
				#emit_signal("player_entering_lockedDoor_signal")
				#print("player walk, he will call Desappear() func???")
				is_moving = false
				stop_input = true
				$AnimationPlayer.play("Desappear")	# in the end of this animation, the func "entered_door()" daqui de player é chamada
				$Camera2D.clear_current()
			else:
				is_moving = false
		else:
			is_moving = false
			#print("Oh no, It's closed!!")
	
	elif (ledge_ray.is_colliding() && input_direction == Vector2(0, 1)) or jumping_over_ledge:
		percent_moved_to_next_tile += jump_speed * delta
		if percent_moved_to_next_tile >= 2.0:
			position = initial_position + (input_direction * TILE_SIZE * 2)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			jumping_over_ledge = false
			shadow.visible = false
			
			var dust_effect = LandingDustEffect.instance()
			dust_effect.position = position
			get_tree().current_scene.add_child(dust_effect)
			
		else:
			shadow.visible = true
			jumping_over_ledge = true
			# the equasion below make the jump a little curve, not linear (jump effect on Isometric 2D game)
			var input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 * pow(input, 2))
	
	# #modJumpLedge to up direction (-y, jump ledge from bottom to top of the ledges)
	# {
	elif (ledge_ray.is_colliding() && input_direction == Vector2(0, -1)) or jumping_over_ledge:
		percent_moved_to_next_tile += jump_speed * delta
		if percent_moved_to_next_tile <= 2.0:
			position = initial_position + (input_direction * TILE_SIZE * 2)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			jumping_over_ledge = false
			shadow.visible = false
			
			var dust_effect = LandingDustEffect.instance()
			dust_effect.position = position
			get_tree().current_scene.add_child(dust_effect)
			
		else:
			shadow.visible = true
			jumping_over_ledge = true
			# the equasion below make the jump a little curve, not linear (jump effect on Isometric 2D game)
			var input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 * pow(input, 2))
	# }

	elif !ray.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("player_moving_signal")
		# the amount of time passed since the last frame
		percent_moved_to_next_tile += walk_speed * delta
		#print("% to next tile: " + String(percent_moved_to_next_tile))
		#print("walk_speed: " + String(walk_speed))	# 0.13 -> 0.20 -> 0.26 -> 0.933333 + (4 * 0.016667) = 1.000001
		#print("delta: " + String(delta))	# 1 + (4 * 0.016667) = 1.066668
		if percent_moved_to_next_tile >= 1.0:
			# player move 16 pixels to the left or right (tile_size = 16 and input_direction is "-1" or "1")
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		is_moving = false
			
