extends "res://Scripts/StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	#add_state("throw_rock")
	call_deferred("set_state", states.idle)

func _input(event):
	# create a array of values U like to check, then check if the array contain the values that U want
	if [states.idle, states.run].has(state):
		# jump
		if (event.is_action_pressed("ui_up")):	# and parent.is_grounded
			# if holding down and grounded then drop through platform instead.
			if (Input.is_action_pressed("ui_down")):
				# check one-way raycasts to prevent getting stuck on solid ground.
				if (parent._check_is_grounded(parent.drop_thru_raycasts)):
					# unset drop_thru_bit, so that player's kinematic body stops colliding with drop_thru layer.
					parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
			# otherwise, actually jump.
			else:
				parent.velocity.y = parent.max_jump_velocity
				parent.is_jumping = true
	
	if (state == states.jump):
		# Variable jump
		if (event.is_action_released("ui_up") && parent.velocity.y < parent.min_jump_velocity):
			parent.velocity.y = parent.min_jump_velocity
	

func _state_logic(delta):
	#print("PlayerFSM, _state_logic(delta)")
#	if (parent.velocity.x >= 0 and parent.velocity.x < 150 or parent.velocity.x < 0 and parent.velocity.x > -150):		# check when run animation should stop (bear stop move but his run animation continues playing because between 1 and 0 there is a lot of floats numbers)
	#if (parent.velocity.x >= 150 or parent.velocity.x <= -150):	# check max velocity
#		print("player_vel: "+String(parent.velocity))
	#print("_check_is_grounded(): " + String(parent._check_is_grounded()))
	#print("get_collision_mask_bit(DROP_THRU_BIT): " + String(parent.get_collision_mask_bit(parent.DROP_THRU_BIT)))
	if (parent.DROP_THRU_BIT != 1):
		print("DROP_THRU_BIT: " + String(parent.DROP_THRU_BIT))		# never was called, It's always = 1, right ??!
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(delta):
	match state:
		states.idle:
			if (!parent.is_on_floor()):
				if (parent.velocity.y < 0):
					return states.jump
				elif (parent.velocity.y > 0):
					return states.fall
			elif (parent.velocity.x != 0):
				return states.run
	#		elif (parent.throwing_rock):
	#			parent.velocity = Vector2.ZERO
	#			return states.throw_rock
		states.run:
			if (!parent.is_on_floor()):
				if (parent.velocity.y < 0):
					return states.jump
				elif (parent.velocity.y > 0):
					return states.fall
			elif (parent.velocity.x == 0):
				return states.idle
		states.jump:
			if (parent.is_on_floor()):
				return states.idle
			elif (parent.velocity.y >= 0):
				return states.fall
		states.fall:
			if (parent.is_on_floor()):
				return states.idle
			elif (parent.velocity.y < 0):
				return states.jump
	#	states.throw_rock:
	#		parent.throwing_rock == false
	#		parent.velocity = Vector2.ZERO
	#		parent.spawn_rock()
	#		return states.idle
			#if(parent.throwing_rock == false):
			#	return states.idle
	
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.anim_player.play("idle")
			parent.emit_signal("grounded_updated", true)
		states.run:
			parent.anim_player.play("run")
		states.jump:
			parent.anim_player.play("jump")
			parent.emit_signal("grounded_updated", false)
		states.fall:
			parent.anim_player.play("fall")
			parent.emit_signal("grounded_updated", false)
	#	states.throw_rock:
			#parent.velocity = Vector2.ZERO
	#		parent.anim_player.play("throw")
			#parent.spawn_rock()
	#	states.death:
	#		parent.anim_player.play("death_forward")

func _exit_state(old_state, new_state):
	pass
