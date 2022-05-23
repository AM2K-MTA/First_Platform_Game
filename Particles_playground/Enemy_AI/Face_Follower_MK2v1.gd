extends KinematicBody2D

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
const vision : int = 10 * Globals.UNIT_SIZE # original code is 600, but I want that the vision can see player if he is at least 10 tiles far away from "self"

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)
var hit_pos
var eyes_pos

var debug_count = 0

func _ready():
	set_process(true)

func set_dir(target_dir):
	if (next_dir != target_dir):
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time

func sees_player():
	hit_pos = []
	eyes_pos = []
	
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)
	
	eyes_pos.append(eye_center)
	eyes_pos.append(eye_top)
	eyes_pos.append(eye_left)
	eyes_pos.append(eye_right)
	
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
				hit_pos.append(collision.position)
				return true
	return false

func _process(delta):
#	print("On ", self.name, ", sees_player: ", sees_player())
	update()
	
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

func _draw():
	if (hit_pos != null):
		var dist = 0.0
		for eye in eyes_pos:
#			print("On ", self.name, ", get eyes pos: ", eye)
			var cur_dist = (eye - position).distance_to(player.position - position)
			
			if (cur_dist < (vision)):	# < 150 is OK
				dist = cur_dist
				laser_color = Color(0, 0, 1, 1)
			else:
				laser_color = Color(1, 0, 0, 1)
			
			draw_circle(eye - position, 8, laser_color)
#			draw_line(eye - position, player.position - position, laser_color)
		
		if (Input.is_key_pressed(KEY_Z) and debug_count == 0):
#			print("On ", self.name, ", player.pos: ", player.position, ", player.globalPos: ", player.global_position)
			print("On ", self.name, ", dist: ", dist)
			debug_count += 1
		if (Input.is_key_pressed(KEY_X)):
			debug_count = 0
		
		for hit in hit_pos:
			# The raycast that work looks to be the "eye_center", is It something wrong on "sees_player()", isn't It?
			draw_circle((hit - position), 5, laser_color)
			draw_line(Vector2(), (hit - position), laser_color)
