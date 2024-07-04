extends Node

const DEDICATED_SERVER_PORT = 8080

func _ready():
	pass
	multiplayer.server_relay = false
	
	if DisplayServer.get_name() == "headless":
		print ("Automatically starting dedicated server.")
		become_host(DEDICATED_SERVER_PORT).call_deferred()
	#if (OS.has_feature("dedicated_server")):
		#print ("Starting dedicated server...")
		#become_host(DEDICATED_SERVER_PORT)

func become_host(server_port):
	print ("Hosting the game!")
	
	GameManager.multiplayer_mode_enabled = true
	GameManager.host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(server_port)
	
	if (server_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED):
		print ("Failed to start multiplayer server.")
		return
	
	multiplayer.multiplayer_peer = server_peer
	
	start_game()

func join_game(server_ip, server_port):
	print ("Joining the game!")
	
	GameManager.multiplayer_mode_enabled = true
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(server_ip, server_port)
	
	if (client_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED):
		print ("Failed to start multiplayer client.")
		return
	
	multiplayer.multiplayer_peer = client_peer
	start_game()
	
func start_game():
	$MenuControl.hide()
	if (multiplayer.is_server()):
		change_level.call_deferred(load("res://scenes/level_1.tscn"))
	
func change_level(scene: PackedScene):
	var level = $Level
	for object in level.get_children(): #clear old level
		level.remove_child(object)
		object.queue_free()
		
	level.add_child(scene.instantiate())

