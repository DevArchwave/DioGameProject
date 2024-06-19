extends Node

@export var mobSpawner: MobSpawner
@export var initial_spawn_rate: float = 30
@export var spawn_rate_per_minute: float = 30
@export var wave_duration: float = 20
@export var breakIntensity: float = 0.5


var time: float = 0

func _ready() -> void:
	mobSpawner.mobsPerMinute = initial_spawn_rate

func _process(delta: float) -> void:
	if GameManager.isGameOver == true: return

	time += delta

	#Linear difficulty
	var spawn_rate = initial_spawn_rate + (spawn_rate_per_minute * (time / 60.0))

	#Wave system
	var sin_wave = sin((time*TAU) / wave_duration)
	#remap is magical
	var wave_factor = remap(sin_wave, -1.0, 1.0, breakIntensity, 1)
	spawn_rate *= wave_factor
	mobSpawner.mobsPerMinute = spawn_rate
	#print(mobSpawner.mobsPerMinute)
	#print("Time: %.2f, Wave: %.2f" % [time, wave])
