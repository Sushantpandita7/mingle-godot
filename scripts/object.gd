extends RigidBody2D

var screen_size: Vector2
@export var move_speed = 120

@export var texture: Texture2D:
	set(value):
		texture = value
		if is_inside_tree():
			$Sprite2D.texture = texture
			
@export var visual: ObjectVisual:
	set(value):
		visual = value
		apply_visual()

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	
	lock_rotation = true
	rotation = 0.0
	angular_velocity = 0.0
		
	if texture:
		$Sprite2D.texture = texture

func _physics_process(_delta):
	
	rotation = 0.0
	angular_velocity = 0.0
	
	if linear_velocity.length() > 0:
		linear_velocity = linear_velocity.normalized() * move_speed

	handle_screen_bounce()	

func handle_screen_bounce():
	var pos = position
	var vel = linear_velocity
	
	if pos.x <= 0 or pos.x >= screen_size.x:
		vel.x *= -1
	if pos.y <= 0 or pos.y >= screen_size.y:
		vel.y *= -1
	
	linear_velocity = vel

func set_initial_motion(velocity: Vector2, angular: float):
	linear_velocity = velocity
	angular_velocity = angular

func apply_visual():
	if not visual:
		return

	$Sprite2D.texture = visual.texture
	$Sprite2D.scale = visual.scale

	var shape := CircleShape2D.new()
	shape.radius = visual.collision_radius
	$CollisionShape2D.shape = shape
