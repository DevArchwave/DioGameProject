extends Node

signal onGameOver

var RNG = RandomNumberGenerator.new()
var currentSeed

var player: Player
var playerPosition: Vector2
var playerGold: int = 0
var goldCollectedThisSession: int = 0
var unitsDefeated: int = 0
var unitsDefeatedThisSession: int = 0
var timeSurvivedThisSession: String = ""
var isGameOver: bool = false

func _ready():
	RNG.randomize() 
	currentSeed = RNG.get_seed()

#Easy probability func, if you pass in 25.0 there will be a 25% chance that the function returns true.
func runProbability(chance_percentage: float) -> bool:
	var random_value: float = RNG.randf() * 100
	return random_value < chance_percentage

func endGame():
	if isGameOver == true: return
	isGameOver = true
	onGameOver.emit()

func cleanUpAfterGameOver():
	RNG.randomize() 
	currentSeed = RNG.get_seed()
	player = null
	playerPosition = Vector2.ZERO
	playerGold += goldCollectedThisSession
	goldCollectedThisSession = 0
	unitsDefeated += unitsDefeatedThisSession
	unitsDefeatedThisSession = 0
	timeSurvivedThisSession = ""
	isGameOver = false
	for connection in onGameOver.get_connections():
		onGameOver.disconnect(connection.callable)
