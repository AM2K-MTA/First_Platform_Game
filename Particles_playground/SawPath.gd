extends Path2D

# Link tutorial: https://youtu.be/EIX7JYVTz44

onready var pathFollow : PathFollow2D = get_node("PathFollow2D")
onready var saw : Area2D = get_node("PathFollow2D/Saw_Area2D")

export(int) var speed
export(int) var direction = 1	# this should be on "saw"

var step : float = 0.0

func _process(delta):
#	if (saw.can_interact):
	step += delta
	pathFollow.offset = step * speed * direction


func _on_Saw_Area2D_body_entered(body):
	print(body.name, " collide with me, haha!!")
	
