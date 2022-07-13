extends KinematicBody2D

onready var player = Globals.global_player
onready var sprite = get_node("Sprite")
onready var lbl_owner_name = get_node("lbl_ownerName")
onready var lbl_status = get_node("lbl_status")
onready var lbl_gui_debug = get_node("lbl_GUI_forDebug")

var owner_changed = false
var my_owner := "I am Savage!"
var moving_left = true

var vel = Vector2(0, 0)
var grav = 1800
var max_grav = 3000

var target = null

var is_interpolation_called = false

func _ready():
	set_color_mood("red")
	set_process(true)

func _process(delta):
	update()
	set_owner_mode(delta)
	
#	debug_print_string(str_toPrint, var_toPrint)
	
	if (target == null):	# target = player
		if (my_owner != "Owner is Player!"):
#			debug_print_string("on func process(), target is null and my_owner not player!", null)
			patrol()
		elif(my_owner == "Owner is Player!"):
			vel = Vector2()
			lbl_status.text = "??!"
	elif(target):
		if (my_owner != "Owner is Player!"):
			attack_target(target, delta)	# Not implemented yet!
		elif(my_owner == "Owner is Player!"):
			interact_with_owner()	# Not implemented yet!
	
	implement_gravity(delta)
	vel = move_and_slide(vel, Vector2(0, -1))

func implement_gravity(_delta):
	vel.y += grav * _delta
	if (vel.y > max_grav):
		vel.y = max_grav
	
	if (is_on_floor() and vel.y > 0):
		vel.y = 0

func patrol():
	if (lbl_status.text != "Patrol"):
		lbl_status.text = "Patrol"

#	debug_print_string("on func patrol, target NOT null and Player is my owner!", null)
	if (get_slide_collision(1)):
		debug_print_string("on func patrol, get slide collision.collider: ", (get_slide_collision(1).collider.name == "Player_mult_FSM"))
#		debug_print_string("moving_left: ", moving_left)
		if (get_slide_collision(1).collider.get_class() == "TileMap"):
			moving_left = !moving_left
	
	vel.x = -100 if moving_left else 100

func interact_with_owner():
	if (lbl_status.text != "Play"):
		lbl_status.text = "Play"
	
func attack_target(get_target, _delta):
	if (lbl_status.text != "Attack"):
		lbl_status.text = "Attack"
	
	vel = Vector2()
	
	var dist = get_target.position - position
	lbl_gui_debug.text = str(dist, ", cur_pos: ", position)
	yield(get_tree().create_timer(1), "timeout")
	
#	if (is_interpolation_called == false):
	if (dist.x >= (32 + 80) or dist.x <= -32):	# call getInterpolation until self/this is very close to player (kinda of 8px to 16px far from player)
		getInterpolation(_delta, dist)

func getInterpolation(_delta, _dist):
	debug_print_string("on func getInterpolation(), test loop...", position.x)
	var temp_pos = position
	var t = 0.0
	var duration = 5.0
	t += _delta / duration
	position = position.linear_interpolate(Vector2(position.x + _dist.x, position.y), min(t, 1.0))
	
func _draw():
	pass

func set_owner_mode(get_delta):
	if (Input.is_action_just_pressed("ui_select")):
		# How to set player as "owner" of this/self (easy way), maybe later change to player gave some fruit/item to gain the trust of the Pet and turn in his owner!
		if (Input.is_key_pressed(KEY_M)):
			owner_changed = true
			if (my_owner == "I am Savage!"):
				my_owner = "Owner is Player!"
				vel = Vector2()
				set_color_mood("pink")
			elif (my_owner == "Owner is Player!"):
				my_owner = "I am Savage!"
				set_color_mood("red")
				position = Vector2(1800, 500)
				is_interpolation_called = false

	if (owner_changed):
#		print("On ", self.name, ", new owner: ", my_owner)
		lbl_owner_name.text = str(my_owner)
		owner_changed = false

# Show the state of self/this to client/player, maybe is temporary until the spritesheet be implemented
func set_color_mood(string_ownerName):
	if (string_ownerName == "red"):
		sprite.modulate = Color(1, 0, 0, 1)
	elif (string_ownerName == "pink"):
		sprite.modulate = Color(1, 0, 1, 1)

func debug_print_string(str_toPrint, var_toPrint):
	print("On ", self.name, ", ", str_toPrint, ": ", str(var_toPrint))

func _on_Area2D_body_entered(body):
#	print("On ", self.name, ", body entered, body is: ", body.name, ", get body group name: ", (body as KinematicBody2D).get_groups())
	if (body == player):
		target = body

func _on_Area2D_body_exited(body):
	target = null
