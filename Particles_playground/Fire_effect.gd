extends Node2D

func _on_Skull_Portal_from_parent_to_particle_should_emitting_signal(should_emitting):
	print("should_emitting my particles, parent Skull_Portal return: " + String(should_emitting))
	$Particles2D.emitting = should_emitting
