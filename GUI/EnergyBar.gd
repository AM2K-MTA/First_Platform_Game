extends HBoxContainer

var maximum_value = 32
var current_energy = 0

func initialize(maximum):
	maximum_value = maximum
	$Gauge.max_value = maximum

func _on_GUI_energy_changed(energy):
	current_energy = energy
	$Gauge.value = energy	# Version with no tween
	$Count/Background/Number.text = "%s / %s" % [energy, maximum_value]	# Version with no tween
