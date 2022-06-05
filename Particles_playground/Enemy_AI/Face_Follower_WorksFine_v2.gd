extends KinematicBody2D

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

var target_player_dist = 128

var eye_reach = 90
const VISION : int = 10 * Globals.UNIT_SIZE # original code is 600, but I want that the vision can see player if he is at least 10 tiles far away from "self"

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)
var hit_pos
var eyes_pos

var debug_count = 0

var target_extents_pos

var Vision_green_player_outside_VISION_canPatrol : bool = true
var Vision_yellow_player_inside_VISION_obstacleBlocking : bool = false
var Vision_red_player_inside_VISION_canAttack : bool = false

# eyesContainers[3]: ["eyeId_right", Color(0,1,0,1)]
# eyesContainers[3][0]: eyeId_right --> String
# eyesContainers[3][1]: 0,1,0,1 --> Color
var eyes_laserColors_container = [
	["eyeId_center", Color(0, 1, 0, 1)], 
	["eyeId_top", Color(0, 1, 0, 1)], 
	["eyeId_left", Color(0, 1, 0, 1)], 
	["eyeId_right", Color(0, 1, 0, 1)]
]

func _ready():
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
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)
	
	eyes_pos.append(eye_center)
	eyes_pos.append(eye_top)
	eyes_pos.append(eye_left)
	eyes_pos.append(eye_right)
	
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
#	print("target_extents_pos: ", target_extents_pos)
	# // } modFixPlayerExtentsPosition Ends
	
	var space_state = get_world_2d().direct_space_state
	
	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [nw, ne, se, sw]:
			if ((corner - eye).length() > VISION):
				Vision_green_player_outside_VISION_canPatrol = true
				Vision_yellow_player_inside_VISION_obstacleBlocking = false
				Vision_red_player_inside_VISION_canAttack = false
		#		print("On ", self.name, ", Player outside vision, corner: ", corner, ", eye: ", eye)
				continue	# ignore the lines below and move foward on that for loop
			var collision = space_state.intersect_ray(eye, corner, [self], self.collision_mask)
			if (collision):
				if (collision.collider.name == "Player_mult_FSM"):
#					print("On ", self.name, ", collision with Player: ", collision.collider.name)
					hit_pos.append(collision.position)
					Vision_green_player_outside_VISION_canPatrol = false
					Vision_yellow_player_inside_VISION_obstacleBlocking = false
					Vision_red_player_inside_VISION_canAttack = true
					return true
			# // { temp code, debug purpose, start
				elif (collision.collider.get_class() == "TileMap"):		# Maybe look for current_level's child node with type 'TileMap', so if the node's name changes, the type doesn't
					# Maybe look for a better place to find player or Change state to "Patrol"
#					print("On ", self.name, ", collision with != Player: ", collision.collider.name, ", collision.collider.get_class(): ", collision.collider.get_class())
					
					# The code below prove that I can compare this for each variable to the original eyes variable (eye_center, eye_top, eye_left, eye_right)
					if (eye == eye_center):
						print("On ", self.name, ", eye center: ", eye)
					elif (eye == eye_top):
						print("On ", self.name, ", eye top: ", eye)
					elif (eye == eye_left):
						print("On ", self.name, ", eye left: ", eye)
					elif (eye == eye_right):
						print("On ", self.name, ", eye right: ", eye)
					
					Vision_green_player_outside_VISION_canPatrol = false
					Vision_yellow_player_inside_VISION_obstacleBlocking = true
					Vision_red_player_inside_VISION_canAttack = false
			# // } temp code, debug purpose, end
	return false

func aim():
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
#	print("target_extents_pos: ", target_extents_pos)
	# // } modFixPlayerExtentsPosition Ends
	
	var space_state = get_world_2d().direct_space_state
	
	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [nw, ne, se, sw]:
			if ((corner - eye).length() > VISION):
				patrol()		# Player not found! Go patrolling
#				break
				continue
			
			var collision = space_state.intersect_ray(eye, corner, [self], self.collision_mask)
			
			if (collision):
				if (collision.collider.name == "Player_mult_FSM"):
#					print("On ", self.name, ", collision with Player: ", collision.collider.name)
					hit_pos.append(collision.position)
					Vision_green_player_outside_VISION_canPatrol = false
					Vision_yellow_player_inside_VISION_obstacleBlocking = false
					Vision_red_player_inside_VISION_canAttack = true
					break
				elif (collision.collider.get_class() == "TileMap"):		# Maybe look for current_level's child node with type 'TileMap', so if the node's name changes, the type doesn't
					# Maybe look for a better place to find player or Change state to "Patrol"
#					print("On ", self.name, ", collision with != Player: ", collision.collider.name, ", collision.collider.get_class(): ", collision.collider.get_class())
					
					# The code below prove that I can compare this for each variable to the original eyes variable (eye_center, eye_top, eye_left, eye_right)
					if (eye == eye_center):
						print("On ", self.name, ", eye center: ", eye)
					elif (eye == eye_top):
						print("On ", self.name, ", eye top: ", eye)
					elif (eye == eye_left):
						print("On ", self.name, ", eye left: ", eye)
					elif (eye == eye_right):
						print("On ", self.name, ", eye right: ", eye)
					
					Vision_green_player_outside_VISION_canPatrol = false
					Vision_yellow_player_inside_VISION_obstacleBlocking = true
					Vision_red_player_inside_VISION_canAttack = false
					break

func patrol():
	Vision_green_player_outside_VISION_canPatrol = true
	Vision_yellow_player_inside_VISION_obstacleBlocking = false
	Vision_red_player_inside_VISION_canAttack = false

func _process(delta):
#	print("On ", self.name, ", sees_player: ", sees_player())
	update()
	
	# Call "aim()" func right below works, but this shoudn't be used like that.
	# The "aim()" should be called after the target was found, in that case It self is look for the target.if target not null, them call "aim()" to see if can attack, or has a obstacle intersect the raycast2D
	# "Turrent_Patrol.tscn" work like that: Player entered on "Turrent_Patrol" Area2D and set the target from "null" to player's node, and 
	aim()
	
	var is_player_lost = Vision_green_player_outside_VISION_canPatrol
	
	if (player.position.x < position.x - target_player_dist and is_player_lost == false):
		set_dir(-1)
	elif (player.position.x > position.x + target_player_dist and is_player_lost == false):
		set_dir(1)
	else:
		set_dir(0)
	
	if (OS.get_ticks_msec() > next_dir_time):
		dir = next_dir
	
	if (OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor()):
		if (player.position.y < position.y - 64 and is_player_lost == false):
			vel.y = jump_height		# Original code "vel.y = -800"
		next_jump_time = -1
	
	vel.x = dir * 300		# Original code: "vel.x = dir * 500"
	
	if (player.position.y < position.y - 64 and next_jump_time == -1 and is_player_lost == false):
		next_jump_time = OS.get_ticks_msec() + react_time
	
	vel.y += grav * delta
	if (vel.y > max_grav):
		vel.y = max_grav
	
	if (is_on_floor() and vel.y > 0):
		vel.y = 0
	
	vel = move_and_slide(vel, Vector2(0, -1))
	
	if (Vision_green_player_outside_VISION_canPatrol):
		# Player not found, go patrol
		laser_color = Color(0, 1, 0, 1)
	elif (Vision_yellow_player_inside_VISION_obstacleBlocking):
		# Player finded, but a obstacle is blocking me, Should I change my path or do something else
		laser_color = Color(1, 1, 0, 1)
	elif (Vision_red_player_inside_VISION_canAttack):
		# Player finded, I can attack him
		laser_color = Color(1, 0, 0, 1)

func _draw():
	if (hit_pos != null):
#		print("On ", self.name, ", hit_pos != null: ", hit_pos, ", hit_pos is empty: ", (hit_pos as Array).empty())
		var dist = 0.0
		for eye in eyes_pos:
#			for corner in target_extents_pos:	# Take player's collisions extents position to use on "cur_dist" variable below
#			print("On ", self.name, ", get eyes pos: ", eye)
			var cur_dist = (eye - position).distance_to(player.position - position)
			
			# for debag purpose, just used to print the dist variable if Input key pressed is true
			if (cur_dist < (VISION)):	# < 150 is OK
				dist = cur_dist
			
			draw_circle(eye - position, 8, laser_color)		# Draw my Eyes
			
			draw_line(eye - position, player.position - position, laser_color)
		
		if (Input.is_key_pressed(KEY_Z) and debug_count == 0):
#			print("On ", self.name, ", player.pos: ", player.position, ", player.globalPos: ", player.global_position)
#			print("On ", self.name, ", dist: ", dist)
			print("On ", self.name, ", eye.length: ", (eyes_pos as Array).size())
			debug_count += 1
		if (Input.is_key_pressed(KEY_X)):
			debug_count = 0
		
		for hit in hit_pos:
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
