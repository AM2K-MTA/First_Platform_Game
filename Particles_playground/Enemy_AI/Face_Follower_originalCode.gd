extends KinematicBody2D

# Link Tutorial (just movement until 17:30), the rest is about make self see the player: https://youtu.be/WXC8eBCEbho
# Seems kinda broke, I have to implement the "_draw" func to draw the raycasts lines.

onready var player = Globals.global_player

var vel = Vector2(0, 0)

var grav = 1800
var max_grav = 3000

var react_time = 400
var dir = 0
var next_dir = 0
var next_dir_time = 0

var next_jump_time = -1

var target_player_dist = 128

var eye_reach = 90
var vision = 600 # vision can see player if he is at least 5 tiles far away from "self"

func _ready():
	set_process(true)

func set_dir(target_dir):
	if (next_dir != target_dir):
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time

func sees_player():
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)
	
	var player_pos = player.get_global_position()
	var player_extents = player.get_node("HurtBox/CollisionShape2D").shape.extents - Vector2(1, 1)
	
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)
	
	var space_state = get_world_2d().direct_space_state
	
	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [top_left, top_right, bottom_left, bottom_right]:
			if ((corner - eye).length() > vision):
				continue	# ignore the lines below and move foward on that for loop
			var collision = space_state.intersect_ray(eye, corner, [], 1)
			if (collision and collision.collider.name == "Player_mult_FSM"):
				return true
	return false

func _process(delta):
#	print("On ", self.name, ", sees_player: ", sees_player())
	
	if (player.position.x < position.x - target_player_dist and sees_player()):
		set_dir(-1)
	elif (player.position.x > position.x + target_player_dist and sees_player()):
		set_dir(1)
	else:
		set_dir(0)
	
	if (OS.get_ticks_msec() > next_dir_time):
		dir = next_dir
	
	if (OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor()):
		if (player.position.y < position.y - 64 and sees_player()):
			vel.y = -800
		next_jump_time = -1
	
	vel.x = dir * 500
	
	if (player.position.y < position.y - 64 and next_jump_time == -1 and sees_player()):
		next_jump_time = OS.get_ticks_msec() + react_time
	
	vel.y += grav * delta
	if (vel.y > max_grav):
		vel.y = max_grav
	
	if (is_on_floor() and vel.y > 0):
		vel.y = 0
	
	vel = move_and_slide(vel, Vector2(0, -1))
