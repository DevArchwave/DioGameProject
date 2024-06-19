class_name GameOverUI
extends CanvasLayer

@onready var timeSurvivedLabel: Label = %TimeSurvivedLabel
@onready var goldCollectedLabel: Label = %GoldCollectedLabel
@onready var unitsDefeatedLabel: Label = %UnitsDefeatedLabel

@export var restartDelay: float = 7.0
var restartCooldown: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeSurvivedLabel.text = "Time Survived: " + str(GameManager.timeSurvivedThisSession)
	goldCollectedLabel.text = "Gold Collected: " + str(GameManager.goldCollectedThisSession)
	unitsDefeatedLabel.text = "Units Defeated: " + str(GameManager.unitsDefeatedThisSession)
	restartCooldown = restartDelay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	restartCooldown -= delta
	if restartCooldown <= 0:
		restartGame()

func restartGame() -> void:
	print("restarting")
	GameManager.cleanUpAfterGameOver()
	get_tree().reload_current_scene()
