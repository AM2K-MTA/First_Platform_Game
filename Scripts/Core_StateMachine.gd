extends StateMachine

func _ready():
	if (parent.name != "SleepingAngel"):
		print("parent is wrong, before change: " + String(parent.name))
		parent = find_parent("SleepingAngel")
		print("parent after change: " + String(parent.name))
	
	add_state("sleep")
	add_state("chase")
	add_state("attack")
	call_deferred("set_state", states.sleep)

func _state_logic(delta):
	parent._apply_gravity(delta)
	
	if (state != states.attack && parent._should_turn()):
		parent._turn()
	
	if (state == states.chase):
		parent._chase_player()
	else:
		parent._stop()
	
	parent._apply_velocity()

func _get_transition(delta):
	match state:
		states.sleep:
			if (parent._should_chase()):
				return states.chase
		states.chase:
			if (parent._should_sleep()):
				return states.sleep
			elif (parent._should_attack()):
				return states.attack
		states.attack:
			if (parent.is_on_floor()):
				return states.sleep
				
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.sleep:
			parent.animation_player.play("rest")
		states.chase:
			parent.animation_player.play("chase")
		states.attack:
			parent.animation_player.play("attack")
			# call the func that makes SleepAngel jump toward the player
			parent.attack()

func _exit_state(old_state, new_state):
	pass
