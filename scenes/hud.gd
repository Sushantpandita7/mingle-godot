extends CanvasLayer

@onready var remaining_value := $RemainingValue
@onready var time_value := $TimeLeftValue

func set_remaining(count: int):
	remaining_value.text = str(count)

func set_time(seconds: float):
	var s := int(ceil(seconds))
	time_value.text = str(s)
