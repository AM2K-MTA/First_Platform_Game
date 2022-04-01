extends Control

signal health_changed(health)
signal esmerald_changed(count)
signal bomb_changed(count)
signal energy_changed(energy)

func _on_Health_health_changed(health):
	emit_signal("health_changed", health)

func _on_Health_maximum_health_changed(max_health):
	$HBoxContainer/Bars/LifeBar.initialize(max_health)
	emit_signal("health_changed", max_health)

func _on_Health_energy_changed(energy):
	emit_signal("energy_changed", energy)

func _on_Health_maximum_energy_changed(max_energy):
	$HBoxContainer/Bars/EnergyBar.initialize(max_energy)
	emit_signal("energy_changed", max_energy)

func _on_Purse_esmerald_changed(count):
	emit_signal("esmerald_changed", count)

func _on_Purse_bomb_changed(count):
	emit_signal("bomb_changed", count)
