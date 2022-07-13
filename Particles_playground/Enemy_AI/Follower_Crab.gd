extends KinematicBody2D

onready var player = Globals.global_player

const WALK_SPEED = 100
const GRAVITY = 600

enum STATES {IDLE, PATROL, PERSUE, ATTACK}
var state = STATES.IDLE

var count = 0

func _ready():
	state = STATES.PATROL

func _physics_process(delta):
	if (player):
		if (Input.is_key_pressed(KEY_I)):
#			print(self.name, ", player name: ", player.name)
			if (Input.is_action_just_pressed("ui_left")):
#				if (count < 4):
#					count += 1 
#				else:
#					count = 1
				if (state == STATES.PERSUE):
					state = STATES.PATROL
				elif (state == STATES.PATROL):
#					print(self.name, ", try count states: ", count)
					state = STATES.PERSUE
		
		var direction = (player.position - position).normalized()
		if not is_on_floor():
			direction.y += GRAVITY
		
		if (state == STATES.PERSUE):
			move_and_slide(direction * WALK_SPEED)
		
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			
			if (collision.collider.name == player.name):
				print(self.name, " said, ", "Die mother fucker!!!")
			
			# Better way to do say to player that He was killed
#			var target = collision.collider
#			if (target.is_in_group("player")):
#				target.die()
