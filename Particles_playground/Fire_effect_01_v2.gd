extends Node2D

func _on_Door_02_v2_from_parent_to_particle_should_emitting_signal(should_emitting):
	print("should_emitting my particles, parent Door_02_v2 return: " + String(should_emitting))
	$Particles2D.emitting = should_emitting
