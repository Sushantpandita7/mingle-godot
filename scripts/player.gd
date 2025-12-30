extends Area2D

@export var speed = 300
var screen_size
var overlapping_objects: Array[RigidBody2D] = []

@export var visual: ObjectVisual

signal collision

func _ready():

	screen_size = get_viewport_rect().size
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	apply_visual()

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
	if not is_instance_valid(target):
		return
	
	if target.visual != visual:
		return	
	overlapping_objects.erase(target)
	var merged_visual: ObjectVisual = target.visual

	$MergeSound.pitch_scale = randf_range(0.8, 2)
	$MergeSound.play()

	target.queue_free()
	
	var main := get_parent().get_parent()
	main.remaining_visuals.erase(merged_visual)

	main.on_object_merged() 

	if main.remaining_visuals.size() > 0:
		switch_to_new_visual()

		
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

func apply_visual():
	if visual:
		$Sprite2D.texture = visual.texture
		$Sprite2D.scale = visual.scale

func switch_to_new_visual():
	var main := get_parent().get_parent()

	if main.remaining_visuals.is_empty():
		return

	visual = main.remaining_visuals.pick_random()
	apply_visual()
