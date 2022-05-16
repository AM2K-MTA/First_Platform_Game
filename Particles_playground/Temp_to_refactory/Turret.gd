extends KinematicBody2D

# Link tutorial: https://youtu.be/lNADi7kTDJ4

export (int) var detect_radius
export (float) var fire_rate
export (PackedScene) var Bullet

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)
var target
var hit_pos
var can_shoot = true

func _ready():
	$Sprite.self_modulate = Color(0.2, 0, 0)
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	$ShootTimer.wait_time = fire_rate

func _physics_process(delta):
	update()	# It's for "_draw()" function
	if (target):
#		rotate_shoot()		# NOT USED! If get the target, just rotate and shoot
		aim()
		
func aim():
	hit_pos = []
	# When used in "_physics_process()", this works like a snapshoot of the physics's state during this frame.
	# U can get info about all physics body and have access to a lot of physics of this world using this object.
	var space_state = get_world_2d().direct_space_state
	# get the corner's position from the target's "CollisionShape2D" and subtract by 5 because the collision shape is little bigger
	var target_extents = target.get_node("CollisionShape2D").shape.extents - Vector2(5, 5)
	# // { get the position of target's corners
	var nw = target.position - target_extents
	var se = target.position + target_extents
	var ne = target.position + Vector2(target_extents.x, -target_extents.y)
	var sw = target.position + Vector2(-target_extents.x, target_extents.y)
	# // }
	
	for pos in [target.position, nw, ne, se, sw]:
		# cast a raycast from Turret's position to the target position (position, target.position)
		# them the 3rd arg is to exclude object that this raycast don't want to intersect/saw ([self])
		# the 4th arg is to get the object that this raycast want to intersect/saw (collision_mask)
		var result = space_state.intersect_ray(position, pos, [self], collision_mask)
		
		if (result):
			hit_pos.append(result.position)
			if (result.collider.name == "Player"):
				$Sprite.self_modulate.r = 1.0
				rotation = (target.position - position).angle()
				if (can_shoot):
					shoot(pos)
				break	# break the for loop when a raycast find the target, so the others are useless and consuming memory, so stop the for loop.

# NOT USED!! This is just to show the easy way to do It, U can use "aim()" for better AI!
func rotate_shoot():
	rotation = (target.position - position).angle()
	if (can_shoot):
		shoot(target.position)

func shoot(pos):
	var b = Bullet.instance()
	var a = (pos - global_position).angle()
	b.start(global_position, a + rand_range(-0.05, 0.05))
	get_parent().add_child(b)
	can_shoot = false
	$ShootTimer.start()
	
func _draw():
	draw_circle(Vector2(), detect_radius, vis_color)
	
	if (target):
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 5, laser_color)
			draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)
	

func _on_Visibility_body_entered(body):
	if (target):
		return
	target = body
	

func _on_Visibility_body_exited(body):
	if (body == target):
		target = null
		$Sprite.self_modulate.r = 0.2

func _on_ShootTimer_timeout():
	can_shoot = true
