extends KinematicBody2D

# link to tutorial: https://www.youtube.com/watch?v=p6OQ7XVsiKw&list=PL4QJmtZWf50kkRSPxNuCBTqB8uY1tsP0N&index=15

const THROW_VELOCITY = Vector2(800, -200)	# 800, -400

var velocity = Vector2.ZERO
var this_was_thrown = false

func _ready():
	#print("Hand projectile is ready!!")
	set_physics_process(false)
	#var this_was_thrown = false

func _physics_process(delta):
	#if (this_was_thrown):
	velocity.y += 1300 * delta	# mod
	#velocity.y += Globals.gravity * delta
	var collision = move_and_collide(velocity * delta)
	if (collision != null):
		_on_impact(collision.normal)

func launch(direction):
	#print("on HFP, launch()")
	
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	velocity = THROW_VELOCITY * Vector2(direction, 1)	# Vector2(direction, 1)
	set_physics_process(true)
	#this_was_thrown = true

func _on_impact(normal: Vector2):
	#print("on HFP, func _on_impact()")
	# make projectile never stop bounce
	velocity = velocity.bounce(normal)
	# Lower the velocity of the projectile every time It's bounced
	velocity *= 0.5 + rand_range(-0.05, 0.05)

func _on_VisibilityNotifier2D_screen_exited():
	#print("I'm out of screen... Hasta la vista!!")
	#queue_free()
	pass	# Doesn't work as expected, should be called after exit the screen, but It's called almost imediatelly after thrown (???)
