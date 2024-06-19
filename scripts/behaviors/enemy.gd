class_name Enemy
extends Node2D

@export var healthValue: int = 10
@export var deathAnimVFXPrefab: PackedScene
@export var damageStrength = 1
@export var damageType = "Blunt"

@export_category("Drops")
@export var itemToSpawn: PackedScene
@export var itemSpawnSpecial: PackedScene
@export var itemSpawnProbability : float = 10

@onready var damageDigitMarker = $DamageDigitMarker

var damageDigitsPrefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damageDigitsPrefab = preload("res://misc/damageDigits.tscn")

func getDamaged(amount: int, type):
	healthValue -= amount
	if healthValue <= 0:
		die()
	colorFeedback()
	
	var damageDigit = damageDigitsPrefab.instantiate()
	damageDigit.value = amount
	if damageDigitMarker:
		damageDigit.global_position = damageDigitMarker.global_position
	else:
		damageDigit.global_position = global_position
	get_parent().add_child(damageDigit)

func colorFeedback():
	modulate = Color.INDIAN_RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func die() -> void:
	if deathAnimVFXPrefab:
		var prefab = deathAnimVFXPrefab.instantiate()
		prefab.position = position
		get_parent().add_child(prefab)
	if itemToSpawn:
		if GameManager.runProbability(itemSpawnProbability):
			#nested probabilities for bigger spawn!
			if itemSpawnSpecial != null && GameManager.runProbability(itemSpawnProbability):
				spawnThing(itemSpawnSpecial)
			else:
				spawnThing(itemToSpawn)
	GameManager.unitsDefeatedThisSession += 1
	queue_free()
	
func spawnThing(thing: PackedScene) -> void:
	var prefab = thing.instantiate()
	prefab.position = position
	get_parent().add_child(prefab)
