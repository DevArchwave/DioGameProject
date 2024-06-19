extends Node

@export var speed: float = 1
@export var characterBody: CharacterBody2D
var animatedSprite : AnimatedSprite2D
var player
var enemy: Enemy
var direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy = get_parent()
	animatedSprite = enemy.get_node("AnimatedSprite2D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if GameManager.isGameOver == true: return
	direction = (GameManager.playerPosition - characterBody.global_position).normalized()
	characterBody.velocity = (direction * speed * 100)
	characterBody.move_and_slide()
	
	if direction.length() > 0:
		animatedSprite.flip_h = direction.x < 0
