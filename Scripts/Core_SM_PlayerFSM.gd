extends "res://Scripts/StateMachine.gd"

func _ready():
	# Sometimes like when player change scene, some state like between paused and idle (like I did on "Scene_Manager", I did "coreFSM.set_physics_process(false) until player spawn on the new scene, them I chenge to true again and player can move")
	# continue... this state like --> add_state("sleep") <-- (not controlable or "set_physics_process(false)"), this could fix the bug mencioned before and the bug that player can throw "Donut" and other guns when physics process is unnabled
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.idle)
	
	if (parent == null or parent.name != "Player_mult_FSM"):
		print("Core_SM_PlayerFSM is ready")
		parent = find_parent("Player_mult_FSM")

func _input(event):
	#print("on core_FSM, _input(event), event/input is called: " + String(event.as_text()))		# get name of the Input event (Key, Mouse button and other devices input)
	# create a array of values U like to check, then check if the array contain the values that U want
	if [states.idle, states.run].has(state):
		# jump
		# Need to ref (refactory) this peace of code below (turn off the colision layer from Player to make him drop thru the drop_throw_platform group)
		# // {
		if (event.is_action_pressed("ui_up")):	# and parent.is_grounded
			parent.set_collision_mask_bit(parent.DROP_THRU_BIT_7, true)		# Enable collision with "Drop_Thru" nodes
			#print("on core, parent.DROP_THRU_BIT_7 bool: " + String(parent.get_collision_mask_bit(parent.DROP_THRU_BIT_7)))
			# if holding down and grounded then drop through platform instead.
			if (Input.is_action_pressed("ui_down")):
				# check one-way raycasts to prevent getting stuck on solid ground.
				if (parent._check_is_grounded2(parent.drop_thru_raycasts)):
					#print("on Core_SM_playerFSM, drop_thru_raycasts, test if work!!")
					# unset drop_thru_bit, so that player's kinematic body stops colliding with drop_thru layer.
					parent.set_collision_mask_bit(parent.DROP_THRU_BIT_7, false)
				
				# mod Fix_Platform // {
				if (parent._check_is_grounded()):
					if (parent.raycasts_collider.has_method("is_in_group")):
						if (parent.raycasts_collider.is_in_group("Drop_Thru_Group")):		# if "col_body" is on group "drop_thru_body", I could do "if (parent._check_is_grounded() and col_body_is_in_group("Drop_Thru_Group")"):
							#print("On core, check is grounded on World layer is true !!!")
							parent.emit_signal("player_drop_require_signal")
							#print("on Core, col_body is on group: " + String(parent.raycasts_collider.is_in_group("Drop_Thru_Group")))
				# mod Fix_Platform // }
		# // }
			# otherwise, actually jump.
			else:
				parent.velocity.y = parent.max_jump_velocity
				parent.is_jumping = true
		elif (event.is_action_pressed("shoot_donut")):
			parent.can_throw_donut = true
			parent.anim_player.play("throw_Donuts")
		elif (event.is_action_pressed("Throw_input")):
			parent.can_throw_hand = true
			#parent.anim_player.play("throw")
			
			print("on Core_SM._input(event), parent.get_collision_mask_bit(DROP_THRU_BIT): " + String(parent.get_collision_mask_bit(2)))
			
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
	if (parent.DROP_THRU_BIT != 2):		# mod original code is: if (parent.DROP_THRU_BIT != 1):
		print("DROP_THRU_BIT: " + String(parent.DROP_THRU_BIT))		# never was called, It's always = 1, right ??!
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()
	
	if (Input.is_action_just_pressed("ui_temp_debug")):		# Key = "K", Just for "testing obj" purpose, go to the end of tilemap
		#print("on Core, temp teleport when ui_select is just pressed!!!!!")
		parent.position = Vector2(2204, 200)
		#print("on Core, to temp debug, player.pos: " + String(parent.position))
		#get_tree().current_scene.gui.set_position(Vector2(20, 30))
		#get_tree().current_scene.gui.set_position(Vector2(20, 30))
		#parent.get_node("Health").take_damage(10)
		#parent.get_node("Health").heal(10)
		
		#parent.get_node("Health").energy_used(10)
		#parent.get_node("Health").energy_recovered(10)
		
		#var newEnemy = load("res://Particles_playground/Enemy_Crab.tscn").instance()
		#newEnemy.position = Vector2(1088, 640)
		#print(newEnemy)
		
	if(Input.is_key_pressed(KEY_SHIFT)):
		#parent.get_node("Health").take_damage(1)
		#parent.get_node("Health").heal(1)
		
		#parent.get_node("Health").energy_used(1)
		parent.get_node("Health").energy_recovered(1)

func _get_transition(delta):
	match state:
		states.idle:
			if (!parent.is_on_floor() and !parent.is_dragged_by_movable_obj):
				#print(parent.is_dragged_by_movable_obj)		# Fix a player's bug (player alternate between "state.idle and state.fall" when "MovingPlatform" is moving up)
				if (parent.velocity.y < 0):
					return states.jump
				elif (parent.velocity.y > 0):
					return states.fall
			elif (parent.velocity.x != 0):
				return states.run
			elif (parent.velocity.x == 0):
				if (parent.can_throw_hand == true):
					parent.velocity = Vector2.ZERO
					parent.anim_player.play("throw", 0)
					parent.anim_player.animation_set_next("throw", "idle")
					parent.spawn_rock()
		states.run:
			if (!parent.is_on_floor() and !parent.is_dragged_by_movable_obj):
				if (parent.velocity.y < 0):
					return states.jump
				elif (parent.velocity.y > 0):
					return states.fall
			elif (parent.velocity.x == 0):
				return states.idle
			elif (parent.is_on_floor() and parent.velocity.x != 0):
				if (parent.can_throw_hand == true):
					#parent.velocity = Vector2.ZERO		# I think It's better let this commented, because the player is running, WHY SHOULD I STOP HIM ?!
					parent.anim_player.play("throw_running", 0)
					parent.anim_player.animation_set_next("throw_running", "run")
					parent.spawn_rock()
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
	#	states.death:
	#		return states.death

	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.print_state_onScreem()
			
			parent.anim_player.play("idle")
			parent.emit_signal("grounded_updated", true)
		states.run:
			parent.print_state_onScreem()
			
			parent.anim_player.play("run")
		states.jump:
			parent.print_state_onScreem()
			
			parent.anim_player.play("jump2")
			parent.emit_signal("grounded_updated", false)
		states.fall:
			parent.print_state_onScreem()
			
			parent.anim_player.play("fall2")
			parent.emit_signal("grounded_updated", false)
	#	states.death:
	#		var get_facing_dir = parent.facing
	#		if (get_facing_dir == -1): # facing left
	#			parent.anim_player.play("death_backward")
	#		if (get_facing_dir == 1): # facing right
	#			parent.anim_player.play("death_forward")

func _exit_state(old_state, new_state):
	pass
