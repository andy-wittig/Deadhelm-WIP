extends Area2D

@export var spawn_enemy_type: Array[PackedScene]
@export var tile_map: TileMap
@export var spawn_range: int
@export var spawn_wait: float

var currently_spawning := false
var spawned_count := 0
var random = RandomNumberGenerator.new()
var spawn_pos: Vector2

@onready var spawner_sprite = $SpawnerSprite
@onready var detect_player = $DetectPlayerCollider
@onready var spawn_timer = $SpawnWaitTimer
@onready var spawn_sound = $SpawnSound

func _process(delta):
	spawner_sprite.material.set_shader_parameter("enabled", false)
	
	for body in get_overlapping_bodies():
		if (body.is_in_group("collectable")): break
		if (body.is_in_group("players") && !currently_spawning):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				spawner_sprite.material.set_shader_parameter("enabled", true)
				if (Input.is_action_just_pressed("pickup")):
					check_enemy_spawnable()
					currently_spawning = true

func _on_input_event(viewport, event, shape_idx):
	for body in get_overlapping_bodies():
		if (body.is_in_group("collectable")): break
		if (body.is_in_group("players") && !currently_spawning):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("left_click")):
					check_enemy_spawnable()
					currently_spawning = true
	
@rpc("any_peer", "call_local")
func spawn_enemy(spawn_position):
	var enemy = spawn_enemy_type[spawned_count-1].instantiate()
	$EnemySpawn.add_child(enemy, true)
	enemy.global_position = spawn_position
	spawn_sound.play()
	
func check_enemy_spawnable():
	spawn_pos = Vector2(global_position.x + random.randi_range(-spawn_range, spawn_range) * 16,
	global_position.y - random.randi_range(0, spawn_range) * 16)
	var test_tile: TileData
	for layer in range(tile_map.get_layers_count()):
		test_tile = tile_map.get_cell_tile_data(layer, tile_map.local_to_map(spawn_pos))
		if (test_tile != null):
			if (test_tile.get_custom_data("spawnable_tile") == false):
				check_enemy_spawnable()
				return
	spawn_timer.start(spawn_wait)

func _on_spawn_wait_timer_timeout():
	if (spawned_count >= spawn_enemy_type.size()):
		spawned_count = 0
		currently_spawning = false
		spawn_timer.stop()
	else:
		spawned_count += 1
		if (!GameManager.multiplayer_mode_enabled):
			spawn_enemy(spawn_pos)
		elif (multiplayer.is_server()):
			rpc_id(1, "spawn_enemy", spawn_pos)	
		check_enemy_spawnable()
