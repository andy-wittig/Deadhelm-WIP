extends Area2D

@export var spawn_enemy_type: Array[PackedScene]
@export var tile_map: TileMap
@export var spawn_range: int
@export var spawn_wait: float
@export var max_spawn_uses := 2

var currently_spawning := false
var spawned_count := 0
var current_spawn_uses := 0
var random := RandomNumberGenerator.new()
var spawn_pos: Vector2

@onready var spawner_sprite = $SpawnerSprite
@onready var detect_player = $DetectPlayerCollider
@onready var spawn_timer = $SpawnWaitTimer
@onready var spawn_sound = $SpawnSound
@onready var vortex_sprite = $VortexSprite

func _process(delta):
	if (current_spawn_uses >= max_spawn_uses):
		$OrbAnimationPlayer.play("deactivate_spawner")
		$OrbSprite.texture = load("res://assets/sprites/level_objects/spawner orb deactivated.png")
	
	spawner_sprite.material.set_shader_parameter("enabled", false)
	
	for body in get_overlapping_bodies():
		if (body.is_in_group("collectable")): break
		if (body.is_in_group("players") && !currently_spawning && current_spawn_uses < max_spawn_uses):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				spawner_sprite.material.set_shader_parameter("enabled", true)
				if (Input.is_action_just_pressed("pickup")):
					check_enemy_spawnable()
					current_spawn_uses += 1
					currently_spawning = true
	
@rpc("any_peer", "call_local")
func spawn_enemy(spawn_position):
	var enemy = spawn_enemy_type[spawned_count-1].instantiate()
	get_tree().get_root().get_node("game/Level").add_child(enemy)
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
	
	if (spawned_count >= spawn_enemy_type.size()):
		vortex_sprite.visible = false
		spawned_count = 0
		currently_spawning = false
		spawn_timer.stop()
		return
	
	vortex_sprite.visible = true
	$VortexSprite/AnimationPlayer.stop()
	$VortexSprite/AnimationPlayer.play("rotate")
	vortex_sprite.global_position = spawn_pos
	spawn_timer.start(spawn_wait)

func _on_spawn_wait_timer_timeout():
		spawned_count += 1
		if (!GameManager.multiplayer_mode_enabled):
			spawn_enemy(spawn_pos)
		elif (multiplayer.is_server()):
			rpc_id(1, "spawn_enemy", spawn_pos)	
		check_enemy_spawnable()
