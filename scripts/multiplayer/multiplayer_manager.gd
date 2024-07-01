extends Node

var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")
var username := ""
var _players_spawn_node
var host_mode_enabled = false
var multiplayer_mode_enabled = false

func become_host(server_port):
	print ("Hosting the game!")
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().tree_changed
	_players_spawn_node = get_tree().get_current_scene().get_node("players")
	
	multiplayer_mode_enabled = true
	host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(server_port)
	
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	_remove_single_player()
	_add_player_to_game(1) #host is id 1

func join_game(server_ip, server_port):
	print ("Joining the game!")
	
	multiplayer_mode_enabled = true
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().tree_changed
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(server_ip, server_port)
	
	multiplayer.multiplayer_peer = client_peer
	
	_remove_single_player()
	
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
	var player_to_remove = get_tree().get_current_scene().get_node("players/player")
	player_to_remove.queue_free()
