extends Control

@onready var menu_layer = $"../.."
@onready var game = $"../../.."
	
func _on_return_button_pressed():
	if (GameManager.multiplayer_mode_enabled): #multiplayer disconnect
		if (multiplayer.is_server()): multiplayer.multiplayer_peer = null
		else: multiplayer.multiplayer_peer.disconnect_peer(1)
		GameManager.multiplayer_mode_enabled = false
		GameManager.host_mode_enabled = false
	GameManager.started_game = false
	game.end_level()
	menu_layer.current_menu = menu_layer.menu.MAIN
	
