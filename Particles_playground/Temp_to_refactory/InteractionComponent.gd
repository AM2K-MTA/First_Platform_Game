extends Area2D

export var interaction_parent : NodePath

signal on_interactable_changed(newInteractable)

# mode here
signal interactable_target_finded_signal(newInteractable)
signal interactable_target_losted_signal(newInteractable)

var interaction_target : Node

# Called every frame
func _process(delta):
	# Check whether the player is trying to interact
	if (interaction_target != null and Input.is_action_just_pressed("interact")):
		# If so, we'll call interaction_interact() if our target supports it
		if (interaction_target.has_method("interaction_interact")):
			interaction_target.interaction_interact(self)


# Signal triggered when our collider collides with something on the interaction layer
func _on_InteractionComponent_body_entered(body):
	
	var canInteract := false
	
	# GDScript lacks the concept of interfaces, so we can't check whether the body implements an interface
	# Instead, we'll see if it has the methods we need
	if (body.has_method("interaction_can_interact")):
		# Interactables tell us whether we're allowed to interact with them.
		canInteract = body.interaction_can_interact(get_node(interaction_parent))
	
	if not canInteract:
		return
		
	# Store the thing we'll be interacting with, so we can trigger it from _process
	interaction_target = body
	emit_signal("on_interactable_changed", interaction_target)
	
	# mod (try to send to Player-InteractionComponentUI which one is that target)
	#print("I Spy with my little eyes something interactable!")
	if (interaction_target != null):
		#print(interaction_target.name)
		# Say to LockedDoor that player is close and he can enter
		if (interaction_target.name == "LokedDoor"):
			var colliderId = find_parent("CurrentScene").get_children().back().find_node("LokedDoor")
			colliderId.player_interact_with_LokedDoor_OPEN = true
			#print("---------------------------- !true! player_interact_with_LokedDoor_OPEN !true! ------------------------")
		
		#mod here (try IC_UI get worked)
		emit_signal("interactable_target_finded_signal", interaction_target)

func _on_InteractionComponent_body_exited(body):
	if (body == interaction_target):
		var thisBody = body
		var colliderId = find_parent("CurrentScene").get_children().back().find_node("LokedDoor")
		
		interaction_target = null
		emit_signal("on_interactable_changed", null)
		emit_signal("interactable_target_losted_signal", interaction_target)
		
		# Say to LockedDoor that player EXIT this area and he can NOT enter (he isn't interacting anymore)
		if (thisBody == colliderId):
			#print("ok here")
			thisBody.player_interact_with_LokedDoor_OPEN = false
