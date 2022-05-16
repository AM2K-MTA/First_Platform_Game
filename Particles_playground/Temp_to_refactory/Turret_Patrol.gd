extends KinematicBody2D

# Link tutorial shooting system: https://youtu.be/lNADi7kTDJ4
# Link tutorial PathFollow and Patrol: https://youtu.be/8UklQumjD2I

# // {	Mod code start
# 1_ var state receive a "String", change to receive a var from a "enum" list (enum = [PATROL, ATTACK] and enum.PATROL = "patrol", so on...)
# 2_ When the player entered on "Visibility" (Area2D), the var "target" = "body" (the body that entered on It), change to: It has to check if that "body" is the Player before do "target = body on func "body_entered()"

# // {	Mod code end

onready var pathfollow : PathFollow2D = get_parent()
onready var hand : Position2D = $Hand_Position2D

export (String, "loop", "linear") var patrol_type = "loop"
export (int) var detect_radius = 250
export (int) var speed : int = 70
export (PackedScene) var Bullet
export (float) var fire_rate = 0.2

var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)
var state : String = "patrol"

var target
var hit_pos
var can_shoot = true

func _ready():
	$Sprite.self_modulate.r = 0.6
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	$ShootTimer.wait_time = fire_rate

func _physics_process(delta):
	update()
	
	if (state == "patrol"):
		patrol(delta)
		
	if (target):
		aim()
	

func change_print_state():
	print("\nOn Turret_Patrol, action1 was pressed, state before: ", state)
	state = "patrol" if state == "attack" else "attack"
	print("\nOn Turret_Patrol, action1 was pressed, state after: ", state)

func patrol(_delta):
	if (patrol_type == "loop"):
		pathfollow.offset += speed * _delta
	else:
		pass

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
	# // } get the position of target's corners
	
	for pos in [target.position, nw, ne, se, sw]:
		var selfPos = pathfollow.position
		var result = space_state.intersect_ray(selfPos, pos, [self], collision_mask)
		
		if (result):
			hit_pos.append(result.position)
			if (result.collider.name == "Player"):
				$Sprite.self_modulate.r = 1.0
				pathfollow.rotation = (target.position - selfPos).angle()
				if (can_shoot):
					shoot(pos)
				break
	

func shoot(pos):
	var b = Bullet.instance()
	var a = (pos - hand.global_position).angle()
	b.start(hand.global_position, a + rand_range(-0.05, 0.05))
	get_tree().current_scene.add_child(b)
	can_shoot = false
	$ShootTimer.start()
	
func _draw():
	draw_circle(Vector2(), detect_radius, vis_color)
	
	if (target):
		for hit in hit_pos:
			draw_circle((hit - pathfollow.position).rotated(-pathfollow.rotation), 5, laser_color)
			draw_line(Vector2(), (hit - pathfollow.position).rotated(-pathfollow.rotation), laser_color)

func _on_Visibility_body_entered(body):
	state = "attack"
	$Sprite.self_modulate.r = 1
	hit_pos = (body as KinematicBody2D).get_global_position()

	if (target):
		return
	target = body
	

func _on_Visibility_body_exited(body):
	if (body == target):
		state = "patrol"
		target = null
		$Sprite.self_modulate.r = 0.2
		yield(get_tree().create_timer(1), "timeout")
	

func _on_ShootTimer_timeout():
	can_shoot = true
