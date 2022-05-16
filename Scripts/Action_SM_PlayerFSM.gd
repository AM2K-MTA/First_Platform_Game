extends StateMachine

func _ready():
	add_state("none")
	add_state("throw_fist")
	call_deferred("set_state", states.none)
	
	if (parent == null or parent.name != "Player_mult_FSM"):
		print("Action_SM_PlayerFSM is ready")
		parent = find_parent("Player_mult_FSM")

func _get_transition(delta):
	match state:
		states.none:
			if (Input.is_action_pressed("Throw_input") && can_throw_fist()):
				#print("parent.state: " + String(parent.core_SM.state))
				parent.end_throw_anim_bool = false
				parent.velocity = Vector2.ZERO
				parent.spawn_rock()
				return states.throw_fist
		states.throw_fist:
			#if (!Input.is_action_pressed("Throw_input") || !can_throw_fist()):
			#	return states.none
			#print("parent.velocity.x: " + String(parent.velocity.x))
			#print("parent.state: " + String(parent.core_SM.state))
			if (parent.end_throw_anim_bool):
				print("___ # ___ On Action_SM_PlayerFSM, get_transition(), throw anim ends, return state none!")
				return states.none

func _enter_state(new_state, old_state):
	match new_state:
		states.none:
			parent.print_state_onScreem()
			
			parent.anim_player.play("death_forward")
		states.throw_fist:
			parent.print_state_onScreem()
			
			parent.anim_player.play("throw", 0)

func can_throw_fist() -> bool:
	var main_states = parent.core_SM.states
	return ![main_states.jump, main_states.fall].has(parent.core_SM.state)
