extends Node2D

func _on_Area2D_body_entered(body):
	print("on Esmerald, body entered in my area!")
	modulate = Color("#725151")
	if (body.name == "Player_mult_FSM"):
		#print(body.name)
		body.get_node("Purse").item_collected(self, "Esmerald")
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()

func _on_Area2D_body_exited(body):
	print("on Esmerald, body exited in my area!")
	modulate = Color("#ffffff")
