extends RigidBody2D

var screen_size: Vector2

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

	if texture:
		$Sprite2D.texture = texture

func _physics_process(_delta):
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
