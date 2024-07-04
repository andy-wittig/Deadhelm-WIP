extends Node2D

@export var spawn_enemy_path: PackedScene
@export var tile_map: Node
@export var spawn_range: int

var random = RandomNumberGenerator.new()

func _ready():
	pass
	
func _process(_delta):
	pass
	
@rpc("call_local")
func spawn_enemy(spawn_position):
	print ("hey!")
	var enemy = spawn_enemy_path.instantiate()
	enemy.position = spawn_position
	get_tree().get_root().add_child(enemy)
	
func check_enemy_spawnable():
	var rand_x_pos = position.x + random.randi_range(-spawn_range, spawn_range)
	var rand_y_pos = position.y + random.randi_range(-spawn_range, spawn_range)
	
	#var tile_map = get_tree().get_current_scene().get_node("TileMap")
	var test_tile = tile_map.get_cell_tile_data(0, Vector2(rand_x_pos, rand_y_pos))
	if (test_tile == null):
		rpc("spawn_enemy", Vector2(rand_x_pos, rand_y_pos))
		return
	elif (test_tile.get_custom_data("spawnable_tile")):
		rpc("spawn_enemy", Vector2(rand_x_pos, rand_y_pos))
		return
	else:
		check_enemy_spawnable()
