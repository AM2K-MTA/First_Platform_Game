extends Node

const UNIT_SIZE = 32	# Original "UNIT_SIZE = 96", but 35 fica até bom
const JUMP_UNIT_SIZE = 50
#const gravity = 200	# old version

# // {		# another modification from Game Endever that I saw on video of "how to create falling platform on godot 3.2"
const PLAYER_JUMP_HEIGHT = -3.25 * UNIT_SIZE	# On Player, has this var and I put (3.25 * 32)
const PLAYER_JUMP_DURATION = 0.5

var gravity
var player

onready var global_player = get_tree().current_scene.find_node("Player_mult_FSM")		# mod ref_Platform

func _ready():
	gravity = -2 * PLAYER_JUMP_HEIGHT / pow(PLAYER_JUMP_DURATION, 2)	
# // }

	if (global_player.name != "Player_mult_FSM"):
		print("on Globals, global_player not find!!! ------------------------------------ ??????")
		global_player = get_tree().current_scene.find_node("Player_mult_FSM")
