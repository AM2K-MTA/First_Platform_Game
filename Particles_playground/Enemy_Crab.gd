class_name Enemy_Crab
extends RigidBody2D

const WALK_SPEED = 50

enum State {
	WALKING,
	DYING,
}

var state = State.WALKING

var direction = -1
var anim = ""

var Bullet = preload("res://Scenes/Donuts.tscn")

onready var rc_left = $RaycastLeft
onready var rc_right = $RaycastRight

func _integrate_forces(s):
	#print("On Enemy_Crab, get_path: " + str(get_path()))
	var lv = s.get_linear_velocity()
	var new_anim = anim

	if state == State.DYING:
		new_anim = "explode"
	elif state == State.WALKING:
		new_anim = "walk"

		var wall_side = 0.0
		
		if $RaycastLeft.is_colliding():	# if looking for "Hand_FistProjectile", go inside this if
			if ($RaycastLeft.get_collider().name != "TileMap2"):
				print("on Enemy_Crab, Bullet colliding with: " + str($RaycastLeft.get_collider().name) + ", good bye world!!")
				if ($RaycastLeft.get_collider().name == "Donuts"):
					# enqueue call
					mode = MODE_RIGID
					state = State.DYING

					physics_material_override.friction = 1
					#cc.disable()
					($SoundHit as AudioStreamPlayer2D).play()
			
		for i in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(i)
			var dp = s.get_contact_local_normal(i)

			if cc:
				#if cc is Bullet and not cc.disabled:	# Original code
				if cc == Bullet:
					print("On Enemy_Crab, if cc blablabla..................... WTF?????")
					# enqueue call
					call_deferred("_bullet_collider", cc, s, dp)
					break

			if dp.x > 0.9:
				wall_side = 1.0
			elif dp.x < -0.9:
				wall_side = -1.0

		if wall_side != 0 and wall_side != direction:
			direction = -direction
			($Sprite as Sprite).scale.x = -direction
		if direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = -direction
		elif direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding():
			direction = -direction
			($Sprite as Sprite).scale.x = -direction

		lv.x = direction * WALK_SPEED

	if anim != new_anim:
		anim = new_anim
		($AnimationPlayer as AnimationPlayer).play(anim)

	s.set_linear_velocity(lv)


func _die():
	queue_free()


func _pre_explode():
	#make sure nothing collides against this
	$Shape1.queue_free()
	$Shape2.queue_free()
	$Shape3.queue_free()

	# Stay there
	mode = MODE_STATIC
	($SoundExplode as AudioStreamPlayer2D).play()


func _bullet_collider(cc, s, dp):
	mode = MODE_RIGID
	state = State.DYING

	s.set_angular_velocity(sign(dp.x) * 33.0)
	physics_material_override.friction = 1
	#cc.disable()
	($SoundHit as AudioStreamPlayer2D).play()
