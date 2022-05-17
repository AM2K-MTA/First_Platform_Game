class_name Crab_Walker
extends KinematicBody2D

# code tutorial's link: https://youtu.be/KXsVXH6055M

onready var rc_wall_detector = $WallDetectorFront
onready var sprite = $Sprite

const GRAVITY = 32
const UP = Vector2.UP

var movement = Vector2()
var speed = 100
var moving_left = true

func _ready():
	#$Sprite.visible = true		# He is invisible and that don't fix It
#	print("____________ on crab, layer: " + str(get_collision_layer_bit(2)))
	pass

func _physics_process(delta):
	movement.y += GRAVITY * delta
	
	if(Input.is_action_just_pressed("ui_down")):
		#print("on Crab_Walker, arrow down was clicked, temp debug, teleport me!")
		position = Vector2(1816, 687 - 100)
	
	if (rc_wall_detector.is_colliding()):
		moving_left = !moving_left
		rc_wall_detector.scale.x = -rc_wall_detector.scale.x
		sprite.scale.x = -sprite.scale.x
	
	move()

func move():
	movement.y += GRAVITY
	
	movement.x = -speed if moving_left else speed
	
	movement = move_and_slide(movement, UP)

func _on_HitBox_L_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Crab_Walker, player entered on HitBox_L area!!")
		(body as KinematicBody2D).was_hitted_side = -1

func _on_HitBox_R_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		print("on Crab_Walker, player entered on HitBox_R area!!")
		(body as KinematicBody2D).was_hitted_side = 1

func _on_HurtBox_body_entered(body):
	if (body.name == "Player_mult_FSM"):
		
		($Hit as AudioStreamPlayer2D).play()
		$AnimationPlayer.play("destroy")