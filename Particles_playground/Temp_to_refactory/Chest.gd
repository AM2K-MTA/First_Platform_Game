extends StaticBody2D

var is_open := false

# mod try instanceate the sprite, not call it inside _ready() func
#onready var sprite = $AnimatedSprite
#onready var anim_player = $AnimationPlayer

func _ready():
	$AnimationPlayer.stop()
	$AnimatedSprite.frame = 0
	is_open = false		# reset is_open in case It's true on start
	
func interaction_can_interact(interactionComponentParent : Node) -> bool:
	return interactionComponentParent is Player
	
	# that code below It's return and do nothing IF Chest is already open (just do something once);
	# With the original code above, he decide to remove the interaction and remove the layer that makes the Chest Interactable;
	# return not is_open and interactionComponentParent is Player	#(code example)
	
# Not implemented - we'll use the default texture instead
#func interaction_get_texture() -> Texture:
#	pass

func interaction_get_text() -> String:
	return "Open"

func interaction_interact(interactionComponentParent : Node) -> void:
	if is_open:
		return
	
	$AnimationPlayer.play("Open")
	is_open = true
	#print("chest was open now")

	# Remove from interaction layer
	# This will cause it to leave the interaction components overlap, which will hide our UI
	# Collision_layer XOR 8 will give all current layers EXCEPT the layer with the bitwsie value 8
	# If you don't know binary, just hover over the layer in the inspector
	# In my case it shows "interactable Bit 3, value 8" <- the value is what we need
	collision_layer = collision_layer ^ 32
