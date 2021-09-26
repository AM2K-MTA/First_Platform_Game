extends Node

signal health_changed(health)
signal health_depleted
signal maximum_health_changed(max_health)

signal energy_changed(energy)
signal energy_depleted
signal maximum_energy_changed(max_energy)

var health = 0
export(int) var max_health = 32

var energy = 0
export(int) var max_energy = 45

func _ready():
	health = max_health
	emit_signal("health_changed", health)
	emit_signal("maximum_health_changed", max_health)
	
	energy = max_energy
	emit_signal("energy_changed", energy)
	emit_signal("maximum_energy_changed", max_energy)

func take_damage(amount):
	health -= amount
	health = max(0, health)
	emit_signal("health_changed", health)

func heal(amount):
	health += amount
	#health = max(health, max_health)	# Original code, make the health = max_health (restore HP completelly ??)
	if(health >= max_health):	# Mod of the code above (That is basically what func max() does, am I wrong?
		health = max_health
	emit_signal("health_changed", health)

func energy_used(amount):
	energy -= amount
	energy = max(0, energy)
	emit_signal("energy_changed", energy)

func energy_recovered(amount):
	energy += amount
	#health = max(health, max_health)	# Original code, make the health = max_health (restore HP completelly ??)
	if(energy >= max_energy):	# Mod of the code above (That is basically what func max() does, am I wrong?
		energy = max_energy
	elif (energy <= 0):
		energy = 0
		print("On Health, energy is over, wait to recover or use healing item!!")
		emit_signal("energy_depleted")
	emit_signal("energy_changed", energy)
