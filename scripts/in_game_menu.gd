extends Control

@onready var menu_layer = $"../.."
@onready var game = $"../../.."

func _on_settings_button_pressed():
	menu_layer.current_menu = menu_layer.menu.SETTINGS

func _on_leave_button_pressed():
	if (!GameManager.multiplayer_mode_enabled):
		game.end_level()
		menu_layer.current_menu = menu_layer.menu.MAIN
	else:
		if (!multiplayer.is_server()):
			GameManager.multiplayer_mode_enabled = false
			GameManager.started_game = false
			multiplayer.multiplayer_peer.disconnect_peer(1)
		else:
			GameManager.multiplayer_mode_enabled = false
			GameManager.host_mode_enabled = false
			GameManager.started_game = false
			multiplayer.multiplayer_peer = null
		game.end_level()
		menu_layer.current_menu = menu_layer.menu.MAIN

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	menu_layer.return_to_prev_menu()
