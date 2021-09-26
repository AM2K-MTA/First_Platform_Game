extends "res://Scripts/StateMachine.gd"

func _ready():
	add_state("WALKING")
	add_state("DYING")
	call_deferred("set_state", states.WALKING)
	
	if (parent == null or parent.name != "Dumb_Crab"):
		print("Core_SM_Dumb_Crab is ready")
		parent = find_parent("Dumb_Crab")

func _state_logic(delta):
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(delta):
	match state:
		states.WALKING:
			if (parent.is_on_floor()):
				#print(parent.is_dragged_by_movable_obj)		# Fix a player's bug (player alternate between "state.idle and state.fall" when "MovingPlatform" is moving up)
				if (parent.velocity.x == 0):
					print("On Core_SM_Dumb_Crab, I'm not moving, Am I dead??????????????")
			elif (!parent.is_on_floor() and !parent.is_dragged_by_movable_obj):
				if (parent.velocity.y > 0):
					#print("On Core_SM_Dumb_Crab, I'm falling!!!!!!!!!!!!")
					#print("pos: " + str(parent.position))
					#return states.fall
					pass
				else:
					print("On Core_SM_Dumb_Crab, if I'm not falling, WTH happens?????????/")
		states.DYING:
			print("On Core_SM_Dumb_Crab, I'm dying, good bye cruel world, until the next.......................")
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.WALKING:
			#parent.print_state_onScreem()
			
			parent.anim_player.play("walk")
			parent.emit_signal("grounded_updated", true)
		states.DYING:
			var get_facing_dir = parent.direction
			if (get_facing_dir == -1): # facing left
				parent.anim_player.play("explode")
			elif (get_facing_dir == 1): # facing right
				parent.anim_player.play("explode")

func _exit_state(old_state, new_state):
	pass
