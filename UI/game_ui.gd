extends CanvasLayer

var timeElapsed: float = 0.0
@onready var timerLabel: Label = $TimerLabel
@onready var goldLabel: Label = %GoldLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#GameManager.player.goldCollected.connect(on_gold_collected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	timeElapsed += delta
	var timeElapsedInSecs: int = floori(timeElapsed)
	var seconds: int = timeElapsedInSecs % 60
	var minutes: int = timeElapsedInSecs / 60
	timerLabel.text = "%02d:%02d" % [minutes, seconds]
	GameManager.timeSurvivedThisSession = timerLabel.text
	goldLabel.text = str(GameManager.goldCollectedThisSession) + " Gold"
