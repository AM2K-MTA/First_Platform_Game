extends Node2D

const IDLE_DURATION = 1.0

export var move_to = Vector2.RIGHT * 192	# original code Vector2.RIGHT * 192 (2 * 96 or 2 * Global.unit_size)
export var speed = 3.0

var follow = Vector2.ZERO

onready var platform = $Platform
onready var tween = $MoveTween

var is_player_colliding_me = false

func _ready():
	_init_tween()
	
	var player = Globals.global_player
	player.connect("player_drop_require_signal", self, "player_dropping")
	
func _init_tween():
	var duration = move_to.length() / float(speed * Globals.UNIT_SIZE)
	# // { This version move the platform, but he add a var "follow", change this lines and made "_physics_process()"
	# make platform move to where I want
#	tween.interpolate_property(platform, "position", Vector2.ZERO, move_to, duration, tween.TRANS_LINEAR, tween.EASE_IN_OUT, IDLE_DURATION)
	# Move It back when It's done
#	tween.interpolate_property(platform, "position", move_to, Vector2.ZERO, duration, tween.TRANS_LINEAR, tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)	# give the time to finish the move
	# // }
	tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, duration, tween.TRANS_LINEAR, tween.EASE_IN_OUT, IDLE_DURATION)
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, tween.TRANS_LINEAR, tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)	# give the time to finish the move
	tween.start()

func _process(delta):
	platform.position = platform.position.linear_interpolate(follow, 0.075)		# 2nd value is "0.075", add  * delta
	
# // {	mod ad drop thru system
func player_dropping():
	#print("On MovingPlatform_GE, signal receive, player droping was called!")
	if (is_player_colliding_me):
		#print("on MovingPlatform_GE, player founded, drop accepted!!!")
		platform.set_collision_layer_bit(1, false)
	else:
		#print("on MovingPlatform_GE, Drop signal receive, but player is not colliding with me")
		pass

func _on_Check_Player_Drop_body_entered(_body):
	#print("on MovingPlatform_GE, body entered called!")
	is_player_colliding_me = true

func _on_Check_Player_Drop2_body_exited(_body):
	#print("on MovingPlatform_GE, body_exited.name: " + String((body as KinematicBody2D).name))
	platform.set_collision_layer_bit(1, true)
	is_player_colliding_me = false
# // }
