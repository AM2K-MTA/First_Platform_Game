extends Sprite
class_name ControllableSpinAtk

# Link tutorial: https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_player_input.html

var speed = 400
var angular_speed = PI

func _ready():
	pass
	
func _process(delta):
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_right"):
		direction = 1

	rotation += angular_speed * direction * delta

	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * speed

	position += velocity * delta

func spin_stop(delta):
	# Spin this obj, If keyIsPressed and arrow_left = -1 elif arrow_left = 1 If !arrow KeyIsPressed = 0 (stop spinning)
	var move_dir = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	rotation += angular_speed * move_dir * delta

	if (Input.is_action_just_pressed("ui_temp_debug")):		# key "K"
		# WHAT DOES: rotation_degrees goes from -360 to 360, this code below make It goes from 0 to -360 or 360.
		# WITHOUT THIS: Without this code below, rotation_degrees doesn't stop at -360/360, It goes throw like -361/361, -362/362, ..., -467/467, -468/468, ...
		var resp = rotation_degrees
		if (resp > 360 or resp < -360):
			resp = int(round(rotation_degrees)) % 360
			rotation_degrees = resp
		
		print("______________ " + str(self.name) + ", get rotation_degrees: " + str(rotation_degrees) + 
		"\nresp: " + str(resp))
		
	
