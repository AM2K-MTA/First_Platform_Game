extends KinematicBody2D

onready var tween = $Tween
onready var anim_player = $AnimationPlayer

const atk_distance = Globals.UNIT_SIZE * 1.5
var atk_direction = 1 setget set_atk_dir, get_atk_dir		# mod to fix direction of the impulse

var life_time = 1.6		# Set to time of the animation "atk_short_1" (now It's "1.6", but I want to change that to "0.8" or less, because It is a fast attack)
var anim_speed = 4		#AnimationPlayer.playback_speed = 4 (play animation 4x faster)

func _ready():
	#print("player: " + str(Globals.global_player.name))
	$Sprite.scale = Vector2(atk_direction, atk_direction)		# mod added fix sprite direction (I did rotete the sprite, the image don't help lol I had to improvise!)
	var player = Globals.global_player
	player.connect("player_require_jeb_punch", self, "_attack")
	#self_destruct()		# I do that on func "_on_AnimationPlayer_animation_finished()"

func _attack(atk_input, atk_dir, player_pos):
	#print("on jeb_Punch, func _attack() was called properly with a signal!!!! attack_input: " + str(atk_input))
	
	if (atk_input == "Simple_ACTION"):
		anim_player.playback_speed = anim_speed
		if (atk_direction == 1):
			atk_direction = atk_dir
			position = player_pos + Vector2(26, -3) * Vector2(atk_dir, 1)
			anim_player.play("right_atk_short_1")
		#elif (atk_direction == -1):
		else:
			atk_direction = atk_dir
			position = player_pos + Vector2(26, -3) * Vector2(atk_dir, 1)
			anim_player.play("left_atk_short_1")
	elif (atk_input == "Special_ACTION"):
		print("on jeb_Punch, func _attack(), atk_input is Special_ACTION, I don't have this animation yet, sorry!!")

func get_atk_dir():
	return atk_direction
func set_atk_dir(dir):
	atk_direction = dir

# create a timer to prevent error like the game try to do something with "this/self" and don't find this node on Tree scenes
func self_destruct():
	yield(get_tree().create_timer(life_time + 0.3), "timeout")
	# Make on AnimationPlayer or animate the sprite.module's Alpha with a Tween or using lerp(), from Alpha 1.0 to 0.0 (invisible)... And them queue_free() self
	queue_free()

# when It's colliding with something, hide youself until "self_destruct()" finish the timer and queue_free()
func _on_Jeb_Punch_body_entered(body):		# Do something when this/self collide with somethimg
	#self.hide()		# I don't need to hide my jeb punch attack with It collide with something, Maybe desabled the collisionShape2D to receive a collision "one time only"
	#pass
	if (body.name == "Player_mult_FSM"):
		return
	elif(body.is_in_group("Enemy")):
		$CollisionShape2D.disabled = true
	elif(body.is_in_group("TileMap_world") or body.is_in_group("Scene_Platform")):
		print("On jeb_Punch, jeb_body_entered, body is in group: " + str(body.get_groups()))
		#pass

# Should be inside a func:
func _on_Damage_Box_body_entered(body):
	$CollisionShape2D.disabled = true		# In the end of the life_time of this hability OR IF get a collision with some enemy DamageBox
	
func _on_AnimationPlayer_animation_finished(anim_name):
	print("on jeb_Punch, anim end")
	#print("on jeb_Punch, check on tree how many jeb_Punch exist: " + str(get_tree().current_scene.has_node("Jeb_Punch")))
	
	yield(get_tree().create_timer(life_time + 0.3), "timeout")
	#yield(get_tree().create_timer(anim_speed + 0.3), "timeout")
	# Make on AnimationPlayer or animate the sprite.module's Alpha with a Tween or using lerp(), from Alpha 1.0 to 0.0 (invisible)... And them queue_free() self
	queue_free()


func _on_AnimationPlayer_animation_started(anim_name):
	print("On jeb_Punch, anim started!")
