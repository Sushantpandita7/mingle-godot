extends Node

enum GameState { WAITING, PLAYING, WIN, LOSE }
var state := GameState.WAITING

@onready var hud := $HUD

@export var player_scene: PackedScene
@export var object_scene: PackedScene

@export var object_min_speed := 100
@export var object_max_speed := 150.0

@export var spawn_visuals: Array[ObjectVisual]

var remaining_visuals: Array[ObjectVisual] = []

var screen_size: Vector2

@export var level_time := 60.0
var time_left := 0.0

func _process(delta):
	if state != GameState.PLAYING:
		return

	time_left -= delta
	hud.set_time(time_left)

	if time_left <= 0:
		check_lose_condition()

func _ready():
	
	state = GameState.WAITING

	screen_size = get_viewport().get_visible_rect().size

	hud.start_pressed.connect(start_level)

	hud.set_remaining(0)
	hud.set_time(level_time)

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
	hud.set_remaining(remaining_visuals.size())

	if remaining_visuals.is_empty():
		trigger_win()

func start_level():
	state = GameState.PLAYING

	remaining_visuals = spawn_visuals.duplicate()

	spawn_player()
	spawn_objects()

	time_left = level_time
	hud.set_remaining($Objects.get_child_count())
	hud.set_time(time_left)
	
func check_lose_condition():
	if $Objects.get_child_count() > 0:
		trigger_lose()
		
func trigger_win():
	state = GameState.WIN
	hud.show_message("YOU WIN")
	$PlayerSpawn.hide()

func trigger_lose():
	state = GameState.LOSE
	hud.show_message("TIME UP")
