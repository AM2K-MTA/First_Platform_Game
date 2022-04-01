extends StaticBody2D

# Editor note: This is my code (based on "OneWayPlatform" and tutorial "Drop thru platform" by GameEndeavor, but I create that drop thru system to fix a bug from original code)

var player = null

var is_player_colliding_me = false

func _ready():
	#print("Fix_Platform is ready!!!")
	var player = Globals.global_player
	player.connect("player_drop_require_signal", self, "player_dropping")

func player_dropping():
	#print("on Fix_Platform, signal receive, player droping was called!")
	if (is_player_colliding_me):
		#print("on Fix_Platform, player founded, drop accepted!!!")
		set_collision_layer_bit(1, false)
	else:
		#print("on Fix_Platform, Drop signal receive, but player is not colliding with me")
		pass

func _on_Check_Player_Drop_body_entered(body):
	#print("on MovingPlatform_GE, body entered called!")
	is_player_colliding_me = true

func _on_Check_Player_Drop_body_exited(body):
	#print("body_exited.name: " + String((body as KinematicBody2D).name))
	set_collision_layer_bit(1, true)
	is_player_colliding_me = false
