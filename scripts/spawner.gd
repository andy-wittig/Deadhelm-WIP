extends Area2D

@export var spawn_enemy_type: PackedScene
@export var tile_map: Node
@export var spawn_range: int
@export var spawn_wait: float
@export var spawn_enemy_amount: int

var currently_spawning := false
var random = RandomNumberGenerator.new()

@onready var spawner_sprite = $SpawnerSprite
@onready var detect_player = $DetectPlayerCollider
@onready var spawn_wait_timer = $SpawnWaitTimer

func _process(delta):
	spawner_sprite.material.set_shader_parameter("enabled", false)
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			spawner_sprite.material.set_shader_parameter("enabled", true)
			if Input.is_action_just_pressed("pickup"):
				check_enemy_spawnable()

func _on_input_event(viewport, event, shape_idx):
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (Input.is_action_just_pressed("left_click")):
				check_enemy_spawnable()
	
@rpc("call_local")
func spawn_enemy(spawn_position):
	var enemy = spawn_enemy_type.instantiate()
	enemy.position = spawn_position
	get_tree().get_root().add_child(enemy)
	
func check_enemy_spawnable():
	var rand_x_pos = position.x + random.randi_range(-spawn_range, spawn_range)
	var rand_y_pos = position.y + random.randi_range(-spawn_range, spawn_range)

	var test_tile = tile_map.get_cell_tile_data(0, Vector2(rand_x_pos, rand_y_pos))
	if (test_tile == null):
		rpc("spawn_enemy", Vector2(rand_x_pos, rand_y_pos))
		return
	elif (test_tile.get_custom_data("spawnable_tile")):
		rpc("spawn_enemy", Vector2(rand_x_pos, rand_y_pos))
		return
	else:
		check_enemy_spawnable()
