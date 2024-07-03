extends Node

const DEDICATED_SERVER_PORT = 8080

var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")
var username := "unknown"
var _players_spawn_node
var host_mode_enabled = false
var multiplayer_mode_enabled = false

func _ready():
	if (OS.has_feature("dedicated_server")):
		print ("Starting dedicated server...")
		become_host(DEDICATED_SERVER_PORT).call_deferred()

func become_host(server_port):
	print ("Hosting the game!")
	
	multiplayer_mode_enabled = true
	host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(server_port)
	
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	start_game()

func join_game(server_ip, server_port):
	print ("Joining the game!")
	
	multiplayer_mode_enabled = true
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(server_ip, server_port)
	multiplayer.multiplayer_peer = client_peer
	
	start_game()
	
func start_game():
	change_level(load("res://scenes/game.tscn"))
	get_tree().get_current_scene().get_node("MenuControl").queue_free()
	_remove_single_player()
	if (multiplayer.is_server()):
		_players_spawn_node = get_tree().get_current_scene().get_node("Level/Game/players")
		_add_player_to_game(1)
	
func change_level(scene: PackedScene):
	var level = get_tree().get_current_scene().get_node("Level")
	for object in level.get_children(): #clear old level
		level.remove_child(object)
		object.queue_free()
		
	level.add_child(scene.instantiate())
	
func _add_player_to_game(id: int):
	print ("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)

func _del_player(id: int):
	print ("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
func _remove_single_player():
	print ("Removing single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Level/Game/players/player")
	player_to_remove.queue_free()
