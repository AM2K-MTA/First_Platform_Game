extends Node2D

signal throw_item()

signal end_throw_anim_signal()

signal end_death_anim_signal()

# throw_Donuts --> animation
signal throw_signal()
signal end_throw_donut_anim_signal()

onready var held_item_position = $Torso/RightArm/HeldItemPosition
