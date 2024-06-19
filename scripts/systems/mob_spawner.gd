class_name MobSpawner
extends Node2D

@onready var pathFollow2D: PathFollow2D = %PathFollow2D

@export var creatureList: Array[PackedScene]

var mobsPerMinute: float = 30.0

@export var numOfSpawnRetries: int = 4

var cooldown: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.isGameOver == true: return
	#timer
	cooldown -= delta
	if cooldown > 0: return
	
	#frequency
	#120 monsters/min = 2 mon per sec
	#intervalo em segundos entre monstros => 60/frequencia
	#60/30 = 2
	#60/60 = 1
	#60/120 = 0.5
	var interval = 60.0 / mobsPerMinute
	cooldown = interval
	
	#check if valid or retry.
	
	#instancing
	trySpawnConsiderValidness(numOfSpawnRetries)

func getViewportPoint() -> Vector2:
	var camera: Camera2D = %Camera2D
	var viewport_rect = camera.get_screen_center_position()
	#var player_position = GameManager.playerPosition # Replace with your player node path
	var spawn_position = Vector2()
	var spawn_margin = 100
	# Determine a random side of the screen to spawn the mob
	match GameManager.RNG.randi_range(0, 3):
		0: # Top
			spawn_position.x = GameManager.RNG.randf_range(viewport_rect.x - camera.get_viewport_rect().size.x / 2, viewport_rect.x + camera.get_viewport_rect().size.x / 2)
			spawn_position.y = viewport_rect.y - camera.get_viewport_rect().size.y / 2 - spawn_margin
		1: # Bottom
			spawn_position.x = GameManager.RNG.randf_range(viewport_rect.x - camera.get_viewport_rect().size.x / 2, viewport_rect.x + camera.get_viewport_rect().size.x / 2)
			spawn_position.y = viewport_rect.y + camera.get_viewport_rect().size.y / 2 + spawn_margin
		2: # Left
			spawn_position.x = viewport_rect.x - camera.get_viewport_rect().size.x / 2 - spawn_margin
			spawn_position.y = GameManager.RNG.randf_range(viewport_rect.y - camera.get_viewport_rect().size.y / 2, viewport_rect.y + camera.get_viewport_rect().size.y / 2)
		3: # Right
			spawn_position.x = viewport_rect.x + camera.get_viewport_rect().size.x / 2 + spawn_margin
			spawn_position.y = GameManager.RNG.randf_range(viewport_rect.y - camera.get_viewport_rect().size.y / 2, viewport_rect.y + camera.get_viewport_rect().size.y / 2)
	return spawn_position
	# Check if the chosen position is out of the player's view
	#if !get_viewport().get_visible_rect().encloses(player_position):
		#var mob_instance = mob_scene.instance()
		#mob_instance.global_position = spawn_position
		#add_child(mob_instance)

func trySpawnConsiderValidness(maxRetries: int):
	var retries = 0
	var spawn_point_valid = false
	var spawn_pos = Vector2.ZERO

	while retries < maxRetries and not spawn_point_valid:
		#spawn_pos = getPoint() # Get a random position from your pathFollow2D
		spawn_pos = getViewportPoint()
		spawn_point_valid = isSpawnPointValid(spawn_pos)
		if spawn_point_valid:
			var index = GameManager.RNG.randi_range(0, creatureList.size() -1)
			var creatureScene = creatureList[index]
			var creature = creatureScene.instantiate()
			creature.global_position = spawn_pos
			get_parent().add_child(creature)
		retries += 1

	if not spawn_point_valid:
		print("Failed to find a valid spawn point after ", maxRetries, " retries.")

func trySpawnDoNotConsiderCollisions():
	var index = GameManager.RNG.randi_range(0, creatureList.size() -1)
	var creatureScene = creatureList[index]
	var creature = creatureScene.instantiate()
	#creature.global_position = getPoint()
	creature.global_position = getViewportPoint()
	get_parent().add_child(creature)

func getFollow2DPoint() -> Vector2: #deprecated
	pathFollow2D.progress_ratio = GameManager.RNG.randf()
	return pathFollow2D.global_position

func isSpawnPointValid(pos: Vector2) -> bool:
	var worldState = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = pos
	parameters.collision_mask = 0b1000 #Only check layer 4
	var result: Array = worldState.intersect_point(parameters, 1) # The second parameter is the maximum number of results
	return result.is_empty() # If empty, no intersection with world limits
