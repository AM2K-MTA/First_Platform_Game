extends Control
class_name InteractionComponentUI

export var interaction_component_nodepath : NodePath

export var interaction_texture_nodepath : NodePath
export var interaction_text_nodepath : NodePath
export var interaction_default_texture : Texture
export var interaction_default_text : String

# mod try to reset the size of HBox and txt width = 100
onready var txt_Label = $HBoxContainer/RichTextLabel

#mod here
onready var label = $HBoxContainer2/Label
export var label_interaction_nodepath : NodePath
export var label_interaction_default_text : String

# mod (try to send to Player-InteractionComponentUI which one is that target)
#signal on_interactable_changed_ICUI(newInteractable)
#var interaction_target_toUI : Node

var fixed_position : Vector2

var abovePlayer_pos := Vector2(155, 16)
var playerPos
var playerPosUI

func _ready():
	# mod try to reset the size of HBox and txt width = 100
	print("IC_UI is ready!")
	#txt_Label.margin_right = 128
	#txt_Label.margin_bottom = 16
	
	# We need to connect ourselves to the interaction components signal
	get_node(interaction_component_nodepath).connect("on_interactable_changed", self, "interactable_target_changed", [], CONNECT_DEFERRED)
	
	# On load we should be hidden
	#mod here
	hide()		# (original code this is not commented, but to see where is this UI, It's should be commented like (#hide()
	
func _process(delta : float):
	# Because we're a child of the player we'll always be moving relative to them
	# But when we're set against an item we should stick above it
	# So each frame we'll make sure we're moved to our fixed_position
	set_global_position(fixed_position)
	
	#playerPos = get_parent().position
	#playerPosUI = get_parent().position + abovePlayer_pos
	#print(playerPos)
	#print(playerPosUI)
	#set_global_position(playerPos)
	
func interactable_target_changed(newInteractable : Node) -> void:
	# If the new interactable thing is null it means we've moved out of range
	# Lets hide our UI
	if (newInteractable == null):
		hide()		#(original code, this hide() is NOT comented, but if I commented (#hide()) I can see where it placed (kinda 150px above player and 50 to the left)
		#mod here (just)
		#print("IC_UI, interactable_target_changed() is out o range")	#To see if work
		return
		
	# Otherwise, we've encountered something new
	# We want to get the icon we should display from it, along with the text
	
	# Start by grabbing our default texture & text
	var interaction_texture := interaction_default_texture
	var interaction_text := interaction_default_text
	
	# Then check whether the interactable has a custom texture
	if (newInteractable.has_method("interaction_get_texture")):
		interaction_texture = newInteractable.interaction_get_texture()
	
	# Or custom text
	if (newInteractable.has_method("interaction_get_text")):
		interaction_text = newInteractable.interaction_get_text()
		
	# We'll update our texture and text
	get_node(interaction_texture_nodepath).texture = interaction_texture
	get_node(interaction_text_nodepath).text = interaction_text
	
	# Record the position we should fix ourselves to
	# This should be just above the interactable item
	fixed_position = Vector2(newInteractable.get_global_position().x - 10, newInteractable.get_global_position().y - 10)
	
	# Move to our fixed position
	self.set_global_position(fixed_position)
	
	#mod here (temp to see when this works, because now, this put the labels far away from player)
	#print(fixed_position)

	# Then ensure we show ourselves
	show()
