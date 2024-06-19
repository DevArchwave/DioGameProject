extends Node2D

@export var regenAmount: int = 10
@onready var area2D: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(onBodyEntered)

func onBodyEntered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player: Player = body
		player.heal(regenAmount)
		player.healthCollected.emit(regenAmount)
		queue_free()
