extends RigidBody2D

var projetile_speed = 400	# original code
var life_time = 3	# original code

var shoot_direction = 1		# mod to fix direction of the impulse

func _ready():
	$Sprite.scale = Vector2(shoot_direction, shoot_direction)		# mod added fix sprite direction (I did rotete the sprite, the image don't help lol I had to improvise!)
	
	#apply_impulse(Vector2(), Vector2(projetile_speed, 0))		# original code
	apply_impulse(Vector2(), Vector2(projetile_speed * shoot_direction, 0))		# with my mod that fix shoot direction
	
	self_destruct()		# original code

# create a timer to prevent error like the game try to do something with "this/self" and don't find this node on Tree scenes
func self_destruct():	# original code
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()

# when It's colliding with something, hide youself until "self_destruct()" finish the timer and queue_free()
func _on_Throw_atk_Punch_body_entered(body):		# original code
	self.hide()
