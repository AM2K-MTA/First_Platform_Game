extends StaticBody2D
class_name LockedDoor

export(String, FILE) var LD_next_scene_path = ""
#export(bool) var LD_is_invisible = false

export(Vector2) var LD_spawn_location = Vector2(0, 0)
export(Vector2) var LD_spawn_direction = Vector2(0, 0)

# Door is_Open (Player can pass Through), is !is_open (Player should not pass)
export(bool) var is_Open = false

# To change the sprite of the Door (Closed and open)
onready var sprite = $Sprite
# To set some animation when the Door is opening or closing (not necessary fo now)
onready var anim_player = $AnimationPlayer

# "player_interact_with_LokedDoor_OPEN" is changed on "InteractionComponent" (true if body_entering, false if body_exited the Interact area of LockedDoor)
var player_interact_with_LokedDoor_OPEN := false
# "player_interact_with_LokedDoor_OPEN" = true and player press the key "Y"
var choose_entering := false
# This is necessary? Because, if is_Open: player could go, if !is_Open: player stop move, right?
var player_entered_LD := false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.stop()
	sprite.frame = 0
	is_Open = false
	player_entered_LD = false
	choose_entering = false
	
	var player = find_parent("CurrentScene").get_children().back().find_node("Player")
	player.connect("player_entering_lockedDoor_signal", self, "enter_door")
	player.connect("player_entered_lockedDoor_signal", self, "close_door")

func _process(delta):
	# "player_interact_with_LokedDoor_OPEN" is changed on "InteractionComponent" (true if body_entering, false if body_exited the Interact area of LockedDoor)
	if (player_interact_with_LokedDoor_OPEN and Input.is_action_just_pressed("YES_option")):
		#print("player say YES, entering this door now")
		# to choose where player want to go (Town or PlayerHome for example), before set "choose_entering = true", this should display a UI_box that ask to player chose his destino, and if is for playerHome,
		# continue... the code below is send and the enter and go to there, if is not, CREATE A BOOL LIKE "change_location = true" and change the path on func "close_door()" right below.
		choose_entering = true
	else:
		choose_entering = false

func enter_door():
	#print("WTF -------------------------- ********* -----------------")
	player_entered_LD = true		# basically this is useless
	#print("signal entering call enter_door() func... Yeah!!")
	# maybe remove the layer "World" from LokedDoor, so the player could pass and activate the "desapear" animation and call "player_entered_lockedDoor_signal" and "close_door" func
	#collision_layer = collision_layer ^ 32		(code example from comment above)

func close_door():
	#print("close_door() was called, but something happens here")
	#print("signal enterED call close_door() func... transition to town??")
	
	# Continue change path from func "_process(delta)": if "change_location = false", continue with the path below, but...
	# ... if "change_location = true", change the path to node and the spawn location and position to player destino escolhido
	get_node(NodePath("/root/SceneManager")).transition_to_scene(LD_next_scene_path, LD_spawn_location, LD_spawn_direction)
	# close the LokedDoor after pass, so other can entering too (and when player comeback he'll see the LokedDoor closed again)
	#player_interact_with_LokedDoor_OPEN = false
	player_entered_LD = false

func interaction_can_interact(interactionComponentParent : Node) -> bool:
	return interactionComponentParent is Player

func interaction_get_text() -> String:
	return "Open"

func interaction_interact(interactionComponentParent : Node) -> void:
	#print("interaction_interact was called")
	
	if (is_Open == false):
		$AnimationPlayer.play("OpenLokedDoor")
		#print("Interact, is_Open = false, play(OpenDoor)")
	else:
		$AnimationPlayer.play("CloseLokedDoor")
		#print("Interact, is_Open = true, play(CloseDoor)")

func door_open():
	#print("LokedDoor is open")
	is_Open = true

func door_closed():
	#print("LokedDoor was closed")
	is_Open = false
