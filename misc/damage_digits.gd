extends Node2D
var value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.text = str(value)
