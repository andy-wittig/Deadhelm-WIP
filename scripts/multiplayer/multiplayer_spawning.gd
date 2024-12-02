extends Node2D

var multiplayer_scene = load("res://scenes/player/multiplayer_player.tscn")

@onready var players_spawn_node = $players

func _ready():
	if (GameManager.multiplayer_mode_enabled):
		_remove_single_player()
	else:
		return
	
	if (not multiplayer.is_server()):
		return
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)

	for id in multiplayer.get_peers():
		_add_player_to_game(id)

	if not OS.has_feature("dedicated_server"):
		_add_player_to_game(1)

func _exit_tree():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(_add_player_to_game)
	multiplayer.peer_disconnected.disconnect(_del_player)
	
func _add_player_to_game(id: int):
	print ("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	players_spawn_node.add_child(player_to_add, true)

func _del_player(id: int):
	print ("Player %s left the game!" % id)
	if not players_spawn_node.has_node(str(id)):
		return
	players_spawn_node.get_node(str(id)).queue_free()
	
func _remove_single_player():
	print ("Removing single player")
	var player_to_remove = players_spawn_node.get_node("player")
	player_to_remove.queue_free()
