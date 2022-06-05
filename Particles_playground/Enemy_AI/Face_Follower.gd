extends KinematicBody2D

# Change if Player is reachable, if there are obstacles that made player unreachable, or if Player is too far away (outside VISION)
#signal vision_status(old_status, new_status)

onready var player = Globals.global_player
onready var sprite = get_node("Sprite")

var vel = Vector2(0, 0)

var grav = 1800
var max_grav = 3000

var react_time = 400
var dir = 0
var next_dir = 0
var next_dir_time = 0

const jump_height = -664
var next_jump_time = -1

# The distance that self/this keep from "player", If player is closer them that I don't look for his position on "_process(delta)"
var target_player_dist = 3 * Globals.UNIT_SIZE		# original code is --> 128 or (4 * Globals.UNIT_SIZE)

# The offset position that positioned the top, left and right eyes from the center_eye's position
var eye_reach = 90
const VISION : int = 10 * Globals.UNIT_SIZE # original code is 600, but I want that the vision can see player if he is at least 10 tiles far away from "self"

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(0, 1, 0, 1)	# Original code = Color(1.0, .329, .298)
var hit_pos
var eyes_pos

var debug_count = 0

var target_extents_pos

enum STATES {IDLE, PATROL, PERSUE, ATTACK}
var state = STATES.IDLE

var Vision_green_player_outside_VISION_canPatrol : bool = true
var Vision_yellow_player_inside_VISION_obstacleBlocking : bool = false
var Vision_red_player_inside_VISION_canAttack : bool = false

var temp_hit_pos := Vector2()

func _ready():
	state = STATES.PATROL
	set_process(true)

func set_dir(target_dir):
	# Maybe something is wrong here...
	# bug:There is a bug that "self" can't see player Unless he jumps;
	#   bugTryFix: Create a signal that look for Player's direction change (if "self" see player on the left and He move to my right side, signal "turnSide_change" is emitted and some func like "turning(old_side = -1, new_side = 1)")
	if (next_dir != target_dir):
		next_dir = target_dir
		if (next_dir != 0):
			sprite.scale.x = next_dir     # modSprite: Try to turn around the "Sprite" to see when direction changes
		next_dir_time = OS.get_ticks_msec() + react_time

func sees_player():
	hit_pos = []
	eyes_pos = []
	
	var eye_center = get_global_position()
	
	eyes_pos.append(eye_center)
	# // { modFixPlayerExtentsPosition Start
	target_extents_pos = []
	# target_extents (player collision shape's extents (the line below) will return Vector2(18, 38) in that case)
	var target_extents = player.get_node("HurtBox/CollisionShape2D").shape.extents
	# The node "player.get_node("HurtBox")" has a different position from his parent player ("Player_mult_FSM.tscn"), IF player.position is Vector2(x, y) && his child ("HurtBox") position is the same as Vector(player.position.x, player.position.y - 8)
	var target_extents_offset = player.get_node("HurtBox").position		# Vector(0, -8)
	var player_POS = player.position + target_extents_offset

	target_extents = target_extents / 2
	var nw = player_POS - target_extents
	var se = player_POS + target_extents
	var ne = player_POS + Vector2(target_extents.x, -target_extents.y)
	var sw = player_POS + Vector2(-target_extents.x, target_extents.y)

	for pos in [player_POS, nw, ne, se, sw]:
		target_extents_pos.append(pos)
	
	var space_state = get_world_2d().direct_space_state
	
	for corner in [nw, ne, se, sw]:
		var cur_dist = eye_center.distance_to(corner)
		
		if (cur_dist < VISION):	# < 150 is OK
			var collision = space_state.intersect_ray(eye_center, corner, [self], self.collision_mask)
		
			if (collision):
				if (collision.collider.name == "Player_mult_FSM"):
	#					print("On ", self.name, ", collision with Player: ", collision.collider.name)
					hit_pos.append(collision.position)
					Vision_green_player_outside_VISION_canPatrol = false
					Vision_yellow_player_inside_VISION_obstacleBlocking = false
					Vision_red_player_inside_VISION_canAttack = true
					return true
				elif (collision.collider.get_class() == "TileMap"):		# Maybe look for current_level's child node with type 'TileMap', so if the node's name changes, the type doesn't
					# Maybe look for a better place to find player or Change state to "Patrol"
	#					print("On ", self.name, ", collision with != Player: ", collision.collider.name, ", collision.collider.get_class(): ", collision.collider.get_class())
					Vision_green_player_outside_VISION_canPatrol = false
					Vision_yellow_player_inside_VISION_obstacleBlocking = true
					Vision_red_player_inside_VISION_canAttack = false
					return true
		else:
#				print("\nOn ", name, ", from sees_player(), Player is too far! Our distance: ", cur_dist)
			Vision_green_player_outside_VISION_canPatrol = true
			Vision_yellow_player_inside_VISION_obstacleBlocking = false
			Vision_red_player_inside_VISION_canAttack = false
			# // } temp code, debug purpose, end
	return false

func patrol():
	Vision_green_player_outside_VISION_canPatrol = true
	Vision_yellow_player_inside_VISION_obstacleBlocking = false
	Vision_red_player_inside_VISION_canAttack = false

func _process(delta):
#	print("On ", self.name, ", sees_player: ", sees_player())
	update()
	
	# Turn around the Sprite if needed
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
			vel.y = jump_height		# Original code "vel.y = -800"
		next_jump_time = -1
	
	vel.x = dir * 300		# Original code: "vel.x = dir * 500"
	
	if (player.position.y < position.y - 64 and next_jump_time == -1 and sees_player()):
		next_jump_time = OS.get_ticks_msec() + react_time
	
	vel.y += grav * delta
	if (vel.y > max_grav):
		vel.y = max_grav
	
	if (is_on_floor() and vel.y > 0):
		vel.y = 0
	
	vel = move_and_slide(vel, Vector2(0, -1))
	
	if (Vision_green_player_outside_VISION_canPatrol):
		# Player not found, go patrol
		if (state == STATES.PATROL):
			pass
		else:
#			print("On ", self.name, ", Vision is GREEN!, state: ", state, ", STATES: ", STATES.keys())
			state = STATES.PATROL
			laser_color = Color(0, 1, 0, 1)
	elif (Vision_yellow_player_inside_VISION_obstacleBlocking):
		# Player finded, but a obstacle is blocking me, Should I change my path or do something else
		if (state == STATES.PERSUE):
			pass
		else:
			state = STATES.PERSUE
#			print("On ", self.name, ", Vision is YELLOW!, state: ", state, ", STATES: ", STATES.keys())
			laser_color = Color(1, 1, 0, 1)
	elif (Vision_red_player_inside_VISION_canAttack):
		# Player finded, I can attack him
		if (state == STATES.ATTACK):
			pass
		else:
			state = STATES.ATTACK
#			print("On ", self.name, ", Vision is RED!, state: ", state, ", STATES: ", STATES.keys())
			laser_color = Color(1, 0, 0, 1)

func _draw():
	if (hit_pos != null):
#		print("On ", self.name, ", hit_pos.size: ", (hit_pos as Array).size())
		
		for target_dot in target_extents_pos:
			draw_line(eyes_pos[0] - position, target_dot - position, laser_color)
		
		if (Input.is_key_pressed(KEY_Z) and debug_count == 0):
#			print("On ", self.name, ", player.pos: ", player.position, ", player.globalPos: ", player.global_position)
#			print("On ", self.name, ", dist: ", dist)
#			print("On ", self.name, ", eye.length: ", (eyes_pos as Array).size())
			print("On ", self.name, ", myPos.x: ", eyes_pos[0].x, ", PlayerPos.x: ", target_extents_pos[0].x)
			print("On ", self.name, ", dist(me, player): ", eyes_pos[0].x - target_extents_pos[0].x)
			debug_count += 1
		if (Input.is_key_pressed(KEY_X)):
			debug_count = 0
		
		for hit in hit_pos:
#			print_last_hit_pos(hit)
			# The raycast that work looks to be the "eye_center", is It something wrong on "sees_player()", isn't It?
#			draw_circle((hit - position), 5, laser_color)
			draw_line(Vector2(), (hit - position), Color(1, 1, 1, 1))
			
			# // { modFixPlayerExtentsPosition Starts
			draw_rect(
				Rect2((target_extents_pos[0] - position) - Vector2(18/2, 38/2), Vector2(18, 38)),
				Color(1, 1, 0, 0.2), true)
			for dot in target_extents_pos:
				draw_circle(dot - position, 4, Color(1, 0, 0, 1))
			# // } modFixPlayerExtentsPosition Ends

func print_last_hit_pos(get_hit):
	if (temp_hit_pos != get_hit):
#		print("On ", name, ", hit pos BEFORE: ", temp_hit_pos)
		temp_hit_pos = get_hit
#		print("On ", name, ", hit pos AFTER: ", get_hit)
		
		draw_rect(
		Rect2((target_extents_pos[0] - position) - Vector2(18/2, 38/2), Vector2(18, 38)),
		Color(1, 1, 0, 0.2), true)
		
		for dot in target_extents_pos:
			draw_circle(dot - position, 4, Color(1, 0, 0, 1))
		
		draw_line(Vector2(), (get_hit - position), Color(1, 1, 1, 1))
