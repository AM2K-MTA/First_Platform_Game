extends HBoxContainer

var maximum_value = 32
var current_health = 0

func initialize(maximum):
	maximum_value = maximum
	$Gauge.max_value = maximum

func _on_GUI_health_changed(health):
	animate_value(current_health, health)
	current_health = health
	#$Gauge.value = health	# Version with no tween
	#$Count/Background/Number.text = "%s / %s" % [health, maximum_value]	# Version with no tween

func animate_value(start, end):
	$Tween.interpolate_property($Gauge, "value", start, end, 0.6, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.interpolate_method(self, "set_count_text", start, end, 0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()
	if (end < start):	# If Player loose health play anim with red modulate
		$AnimationPlayer.play("shake")
	elif (end > start):		#If Player healing play anim with blue/green modulate or some positive animation instead
		$AnimationPlayer.play("healing_effect")

func set_count_text(value):
	$Count/Background/Number.text = str(round(value)) + "/" + str(maximum_value)
