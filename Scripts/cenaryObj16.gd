extends StaticBody2D

onready var get_player = get_tree().current_scene.find_node("player")
#onready var track_playerPos_ray = get_node("RayCast2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("I'm ready")
	#track_playerPos_ray.enabled = false

func _process(delta):
	pass
	#print("pos: " + String(get_player.position))
	#print("Global_pos: " + String(get_player.global_position))
	
#	var newPos = Vector2(get_player.position.x - track_playerPos_ray.global_position.x, get_player.position.y - track_playerPos_ray.global_position.y)
	
#	track_playerPos_ray.cast_to = newPos
#	track_playerPos_ray.force_raycast_update()
