extends CanvasLayer

signal start_pressed

@onready var remaining_value := $RemainingValue
@onready var time_value := $TimeLeftValue
@onready var start_button := $StartButton
@onready var message := $Message

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	message.hide()

func _on_start_pressed():
	start_button.hide()
	emit_signal("start_pressed")

func set_remaining(count: int):
	remaining_value.text = str(count)

func set_time(seconds: float):
	time_value.text = str(int(ceil(seconds)))

func show_message(text: String):
	message.text = text
	message.show()
