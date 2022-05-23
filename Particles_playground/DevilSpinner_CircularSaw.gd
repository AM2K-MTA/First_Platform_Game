extends Sprite

# bug: position problem

onready var anim = get_parent().get_node("AnimationPlayer")

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
	
	# TempCode for debug CircularSaw position
	# Conclusion: His position is change different then expected
	if (Input.is_action_just_pressed("ui_down")):
		print("On ", self.name, ", position: ", position, ", DevilSpinner.pos: ", get_parent().position)

	#aumenta o raio da ellipse
#	offset.x = -rotation/2
