extends "res://Scripts/StateMachine.gd"

func _ready():
	#print("Core_SM_Golem is ready!!")
	add_state("IDLE")
	add_state("WALKING")
	add_state("FALLING")
	add_state("DYING")
	call_deferred("set_state", states.IDLE)
	
	if (parent == null or parent.name != "Golem"):
		print("Core_SM_Golem is ready")
		parent = find_parent("Golem")

func _input(event):
	pass

func _die():
	#print("On Core_SM_Golem, func _die(), BEFORE parent.queue_free(), is parent dead: " + str(parent.is_inside_tree()))
	parent.queue_free()
	#print("On Core_SM_Golem, func _die(), AFTER parent.queue_free(), is parent dead: " + str((parent as KinematicBody2D).is_inside_tree()))
	self.queue_free()

func _state_logic(delta):
	parent._apply_gravity(delta)
	parent._apply_movement()
	
	if(Input.is_action_just_pressed("ui_down")):
		#print("on Crab_Walker, arrow down was clicked, temp debug, teleport me!")
		parent.position = Vector2(914, 669 - 100)
	
	#if (parent.anim_player):
	
func _get_transition(delta):
	match state:
		states.IDLE:
			if(parent.is_dead):
				return states.DYING
				
			if (!parent.is_on_floor() and !parent.is_dragged_by_movable_obj):
				if (parent.movement.y > 0):
					print("On Core_SM_Golem, states.IDLE, I'm falling!!!!!!!!!!!!")
					return states.FALLING
			elif (parent.is_on_floor()):
				return states.WALKING
		states.WALKING:
			#print("parent.movement: " + str(parent.movement))
			if(parent.is_dead):
				return states.DYING
			
			if (parent.is_on_floor()):
				#print(parent.is_dragged_by_movable_obj)		# Fix a player's bug (player alternate between "state.idle and state.fall" when "MovingPlatform" is moving up)
				if (parent.movement.x == 0):
					#print("On Core_SM_Golem, I'm not moving, Am I dead??????????????")
					pass
			elif (!parent.is_on_floor() and !parent.is_dragged_by_movable_obj):
				if (parent.movement.y > 0):
					#print("On Core_SM_Golem, states.WALKING, I'm falling!!!!!!!!!!!!")
					#print("pos: " + str(parent.position))
					return states.FALLING
		states.FALLING:
			#print("On Core_SM_Golem, get_transition(), states.FALLING!")
			if (parent.is_on_floor()):
				return states.IDLE
			#pass
		states.DYING:
			#print("On Core_SM_Golem, I'm dying, good bye cruel world, until the next.......................")
			pass
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.IDLE:
			parent.anim_player.play("idle")
		states.WALKING:
			#parent.print_state_onScreem()
			
			parent.anim_player.play("walk")
			parent.emit_signal("grounded_updated", true)
		states.FALLING:
			parent.anim_player.play("fall")
		states.DYING:
			parent.anim_player.play("explode")

func _exit_state(old_state, new_state):
	pass

