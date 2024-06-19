class_name Player
extends CharacterBody2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var thisSprite2D: Sprite2D = $Sprite2D
@onready var swordArea: Area2D = $SwordSlashArea
@onready var hitboxArea: Area2D = $HitboxArea
@onready var collisionInvincibilityTimer: Timer = $CollisionInvincibilityTimer
@onready var healthBar: ProgressBar = $ProgressBar
@onready var ritualCooldown: float = ritualInterval

@export_category("Attack")
@export var swordDamage: int = 2
@export var attackCooldown: float = 0.6

@export_category("Movement")
@export var speed: float = 3
@export var lerpFactor: float = 0.15

@export_category("Life")
@export var healthValue: int = 30
@export var currentMaxHealth: int = 40
@export var deathAnimVFXPrefab: PackedScene

@export_category("Ritual")
@export var ritualPrefab: PackedScene
@export var ritualDamage: int = 1
@export var ritualInterval: float = 6
@export var ritualScale: float = 1



var defaultControllerDeadZone = 0.15
var inputVector: Vector2 = Vector2(0, 0)
var isRunning: bool = false
var wasRunning: bool = false
var isAttacking: bool = false
var attackCooldownTimer = attackCooldown

var numOfIframes: int = 20
var isCollisionInvincible = false

signal goldCollected(value:int)
signal healthCollected(value:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collisionInvincibilityTimer.wait_time = numOfIframes / 60.0
	GameManager.player = self

func _onInvincibilityTimeout():
	isCollisionInvincible = false

func _process(delta: float) -> void:
	readInput()

	handleMovementAnim()

	#attack
	attackTimerUpdate(delta)
	if Input.is_action_just_pressed("attack1"):
		attack1()

func _physics_process(delta: float) -> void:
	#move character
	var targetVelocity = inputVector * speed * 100
	if isAttacking:
		targetVelocity *= 0.25
	velocity = lerp(velocity, targetVelocity, lerpFactor)
	move_and_slide()
	GameManager.playerPosition = self.global_position
	updateHitboxDamageDetection(delta)
	updateHealthBar()
	updateRitual(delta)

func updateHitboxDamageDetection(delta: float) -> void:
	#timer
	#frequency
	if !isCollisionInvincible:
		var bodies = hitboxArea.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("Enemies"):
				var enemy: Enemy = body
				getDamaged(enemy.damageStrength, enemy.damageType)
				isCollisionInvincible = true
				collisionInvincibilityTimer.start()

func updateHealthBar():
	healthBar.max_value = currentMaxHealth
	healthBar.value = healthValue

func readInput() -> void:
	#get input
	inputVector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	#delete input vector deadzone (thanks me later, controller players!)
	if abs(inputVector.x) < defaultControllerDeadZone:
		inputVector.x = 0
	if abs(inputVector.y) < defaultControllerDeadZone:
		inputVector.y = 0
		
	#update
	wasRunning = isRunning
	isRunning = !inputVector.is_zero_approx()

func handleMovementAnim() -> void:
	#animate
	if !isAttacking:
		if wasRunning != isRunning:
			if isRunning:
				animationPlayer.play("Run")
			else:
				animationPlayer.play("Idle")
		flipSpriteCheck()

func flipSpriteCheck() -> void:
	#flip anim if required
	if inputVector.x > 0:
		thisSprite2D.flip_h = false
	elif inputVector.x < 0:
		thisSprite2D.flip_h = true

func attack1() -> void:
	if isAttacking:
		return
	var variant = randi() % 2 + 1  # Generate a random integer between 1 and 2
	if inputVector.y < 0:  # Up
		animationPlayer.play("attack_up_" + str(variant))
		swordArea.rotation = deg_to_rad(270)
	elif inputVector.y > 0:  # Down
		animationPlayer.play("attack_down_" + str(variant))
		swordArea.rotation = deg_to_rad(90)
	else:  # Side
		animationPlayer.play("attack_side_" + str(variant))
		if thisSprite2D.flip_h:
			swordArea.rotation = deg_to_rad(180)
		else: swordArea.rotation = deg_to_rad(0)
	isAttacking = true
	#dealDamageToEnemies() # no longer here! This is handled by animation player now!

func attackTimerUpdate(delta: float) -> void:
	#attackTimerUpdate
	if isAttacking:
		attackCooldownTimer -= delta
	if attackCooldownTimer <= 0.0:
		isAttacking = false
		attackCooldownTimer = attackCooldown
		isRunning = false
		animationPlayer.play("Idle")

func updateRitual(delta: float) -> void:
	ritualCooldown -= delta
	if ritualCooldown > 0: return
	
	ritualCooldown = ritualInterval
	var ritualMagic: Node2D = ritualPrefab.instantiate()
	ritualMagic.damageAmount = ritualDamage
	ritualMagic.scale = Vector2(ritualScale, ritualScale)
	add_child(ritualMagic)

func dealDamageToEnemies():
	var bodies = swordArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemies"):
			var enemy: Enemy = body
			enemy.getDamaged(swordDamage, "blunt")
			

func dealDamageToEnemiesUsingDotProd():
	var bodies = swordArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemies"):
			var enemy: Enemy = body
			
			var directionToEnemy = (enemy.position - position).normalized()
			var attackDirection: Vector2
			if thisSprite2D.flip_h:
				attackDirection = Vector2.LEFT
			else:
				attackDirection = Vector2.RIGHT
			var dotProduct = directionToEnemy.dot(attackDirection)
			#print("Dot:", dotProduct)
			if dotProduct >= 0.3:
				enemy.getDamaged(swordDamage, "blunt")




func getDamaged(amount: int, type):
	if healthValue <= 0: return
	healthValue -= amount
	print("Player took damage. Health is now: ", healthValue)
	colorFeedback()
	if healthValue <= 0:
		die()

func colorFeedback():
	thisSprite2D.modulate = Color.INDIAN_RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(thisSprite2D, "modulate", Color.WHITE, 0.3)

func die() -> void:
	if deathAnimVFXPrefab:
		var prefab = deathAnimVFXPrefab.instantiate()
		prefab.position = position
		get_parent().add_child(prefab)
	GameManager.endGame()
	queue_free()

func heal(amount: int) -> int:
	healthValue += amount
	if healthValue > currentMaxHealth:
		healthValue = currentMaxHealth
	return healthValue
	
