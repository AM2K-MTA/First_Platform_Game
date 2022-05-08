extends Sprite

onready var anim = $AnimationPlayer

var speed = 400
var angular_speed = PI

var is_effect_time = false

var velocity

func _ready():
	anim.play("sawSpinEffect", 1.0, 1.0, false)
#	pass
	
func _process(delta):
	rotation += angular_speed * delta
	
	velocity = Vector2.UP.rotated(rotation) * (speed)
	position += velocity * delta

	#aumenta o raio da ellipse
#	offset.x = -rotation/2
