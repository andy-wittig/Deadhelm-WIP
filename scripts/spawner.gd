extends Area2D

@export var spawn_enemy_type: Array[PackedScene]
@export var tile_map: TileMap
@export var spawn_range: Vector2
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
			spawner_sprite.material.set_shader_parameter("enabled", true)
			if (Input.is_action_just_pressed("pickup")):
				check_enemy_spawnable()
				current_spawn_uses += 1
				currently_spawning = true

func spawn_enemy(spawn_position):
	var enemy = spawn_enemy_type[spawned_count - 1].instantiate()
	get_tree().get_root().get_node("game/Level").add_child(enemy)
	enemy.global_position = spawn_position
	enemy.reset_physics_interpolation()
	spawn_sound.play()
	
func check_enemy_spawnable():
	if (spawned_count >= spawn_enemy_type.size()):
		currently_spawning = false
		vortex_sprite.visible = false
		$VortexSprite/VortexParticles.emitting = false
		spawned_count = 0
		spawn_timer.stop()
		return
	
	spawn_pos = Vector2(global_position.x + random.randi_range(-spawn_range.x, spawn_range.x) * 16,
	global_position.y - 8 - random.randi_range(0, spawn_range.y) * 16)
	var test_tile: TileData
	for layer in range(tile_map.get_layers_count()):
		test_tile = tile_map.get_cell_tile_data(layer, tile_map.local_to_map(spawn_pos))
		if (test_tile != null):
			if (test_tile.get_custom_data("solid") == false):
				check_enemy_spawnable()
				return
	
	vortex_sprite.visible = true
	$VortexSprite/AnimationPlayer.stop()
	$VortexSprite/AnimationPlayer.play("rotate")
	$VortexSprite/VortexParticles.emitting = true
	vortex_sprite.global_position = spawn_pos
	vortex_sprite.reset_physics_interpolation()
	spawn_timer.start(spawn_wait)

func _on_spawn_wait_timer_timeout():
		spawned_count += 1
		spawn_enemy(spawn_pos)
		check_enemy_spawnable()
