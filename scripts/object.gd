extends RigidBody2D

var screen_size: Vector2
@export var move_speed = 60

@export var texture: Texture2D:
	set(value):
		texture = value
		if is_inside_tree():
			$Sprite2D.texture = texture
			
@export var visual: ObjectVisual:
	set(value):
		visual = value
		apply_visual()

# Movement Behavior
enum MoveState { IDLE, DRIFT, BOOST }

var state: MoveState
var state_timer := 0.0
var direction := Vector2.ZERO

@export var base_speed := 120.0
@export var drift_multiplier := 1
@export var boost_multiplier := 2

var bounds_margin_x := 20.0
var bounds_margin_y := 80.0


func _ready():
	screen_size = get_viewport().get_visible_rect().size
	
	lock_rotation = true
	rotation = 0.0
	angular_velocity = 0.0

	direction = random_direction()
	switch_state(MoveState.DRIFT)

	if texture:
		$Sprite2D.texture = texture

func random_direction() -> Vector2:
	var d := Vector2.ZERO
	while d == Vector2.ZERO:
		d = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	return d.normalized()

func switch_state(new_state: MoveState):
	state = new_state

	match state:
		MoveState.IDLE:
			state_timer = randf_range(0.4, 0.8)
			linear_velocity = Vector2.ZERO

		MoveState.DRIFT:
			state_timer = randf_range(1.5, 3.5)
			direction = random_direction()

		MoveState.BOOST:
			state_timer = randf_range(0.3, 0.6)
			direction = random_direction()


func _physics_process(delta):
	
	rotation = 0.0
	angular_velocity = 0.0

	state_timer -= delta
	if state_timer <= 0:
		pick_next_state()

	apply_movement()
	handle_screen_bounce()

func apply_movement():
	match state:
		MoveState.IDLE:
			linear_velocity = Vector2.ZERO

		MoveState.DRIFT:
			linear_velocity = direction * base_speed * drift_multiplier

		MoveState.BOOST:
			linear_velocity = direction * base_speed * boost_multiplier

func pick_next_state():
	var r := randf()

	if r < 0.15:
		switch_state(MoveState.IDLE)
	elif r < 0.8:
		switch_state(MoveState.DRIFT)
	else:
		switch_state(MoveState.BOOST)

func handle_screen_bounce():
	var bounced := false
	var pos := position
	
	if pos.x < bounds_margin_x:
		pos.x = bounds_margin_x
		direction.x = abs(direction.x)
		bounced = true
	elif pos.x > screen_size.x - bounds_margin_x:
		pos.x = screen_size.x - bounds_margin_x
		direction.x = -abs(direction.x)
		bounced = true

	if pos.y < bounds_margin_y:
		pos.y = bounds_margin_y
		direction.y = abs(direction.y)
		bounced = true
	elif pos.y > screen_size.y - bounds_margin_y:
		pos.y = screen_size.y - bounds_margin_y
		direction.y = -abs(direction.y)
		bounced = true

	if bounced:
		position = pos
		direction = (direction + random_direction() * 0.3).normalized()
		if state == MoveState.BOOST:
			switch_state(MoveState.DRIFT)


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
