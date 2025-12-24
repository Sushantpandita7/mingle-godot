extends Area2D

@export var speed = 300
var screen_size
var overlapping_objects: Array[RigidBody2D] = []

signal collision

func _ready():

	screen_size = get_viewport_rect().size
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body is RigidBody2D:
		overlapping_objects.append(body)
		emit_signal("collision")

func _on_body_exited(body):
	if body is RigidBody2D:
		overlapping_objects.erase(body)

func _process(delta):
	
	var velocity = Vector2.ZERO
	if(Input.is_action_pressed("ui_left")):
		velocity.x = -1
	if(Input.is_action_pressed("ui_right")):
		velocity.x = 1
	if(Input.is_action_pressed("ui_up")):
		velocity.y = -1
	if(Input.is_action_pressed("ui_down")):
		velocity.y = 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if Input.is_action_just_pressed("merge"):
		merge_object()
	
func merge_object():
	cleanup_overlaps()
	
	if overlapping_objects.is_empty():
		return
	# Pick closest object (important when multiple overlap)
	var target := get_closest_object()
	if is_instance_valid(target):
		target.queue_free()
		
func get_closest_object() -> RigidBody2D:
	
	var closest: RigidBody2D = null
	var min_dist := INF
	
	for obj in overlapping_objects:
		if not is_instance_valid(obj):
			continue

		var d = global_position.distance_to(obj.global_position)
		if d < min_dist:
			min_dist = d
			closest = obj

	return closest
	
func cleanup_overlaps():
	overlapping_objects = overlapping_objects.filter(
		func(obj):
			return is_instance_valid(obj)
	)
