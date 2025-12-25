extends Node

@export var player_scene: PackedScene
@export var object_scene: PackedScene

@export var object_count := 5
@export var object_min_speed := 100
@export var object_max_speed := 150.0

@export var spawn_visuals: Array[ObjectVisual]

var remaining_visuals: Array[ObjectVisual] = []

var screen_size: Vector2

@export var level_time := 60.0
var time_left := 0.0

@onready var hud := $HUD

func _process(delta):
	if time_left <= 0:
		return
	time_left -= delta
	hud.set_time(time_left)
	hud.set_remaining($Objects.get_child_count())
	
	#if time_left <= 0:
		#on_time_up()

func _ready():
	
	screen_size = get_viewport().get_visible_rect().size

	remaining_visuals = spawn_visuals.duplicate()

	spawn_player()
	spawn_objects()
	
	time_left = level_time
	hud.set_remaining($Objects.get_child_count())
	hud.set_time(time_left)
	
	$HUD/Remaining.show()
	$HUD/TimeLeft.show()

	#if spawn_visuals.size() != object_count:
		#push_error(
			#"Object count (%d) does not match spawn_visuals size (%d)"
			#% [object_count, spawn_visuals.size()]
		#)
		#return

func spawn_player():

	var player = player_scene.instantiate()
	player.position = screen_size * 0.5

	player.visual = spawn_visuals.pick_random()
	player.apply_visual()

	$PlayerSpawn.add_child(player)

func spawn_objects():
	for i in spawn_visuals.size():
		var obj = object_scene.instantiate()
		obj.position = random_position()
		
		obj.visual = spawn_visuals[i]

		$Objects.add_child(obj)
		
		# Random initial movement
		var dir = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		
		var speed = randf_range(object_min_speed, object_max_speed)
		
		obj.call_deferred(
			"set_initial_motion",
			dir * speed,
			randf_range(-3.0, 3.0)
		)

func random_position() -> Vector2:
	return Vector2(
		randf_range(0, screen_size.x),
		randf_range(0, screen_size.y)
	)

func on_object_merged():
	hud.set_remaining($Objects.get_child_count())
