extends Node

@export var gameUi: CanvasLayer
@export var gameOverUiPrefab: PackedScene

func _ready() -> void:
	GameManager.onGameOver.connect(triggerGameOver)

func triggerGameOver():
	#createGameOverUI
	var gameOverUI: GameOverUI = gameOverUiPrefab.instantiate()
	add_child(gameOverUI)
	
	#delete old GameUi
	if gameUi:
		gameUi.queue_free()
		gameUi = null
