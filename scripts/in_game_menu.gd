extends Control

@onready var menu_layer = $"../.."
@onready var game = $"../../.."

var menu_started := false

func menu_opened():
	if (!menu_started):
		$MenuOptions/BackButton.grab_focus()
		menu_started = true

func _on_settings_button_pressed():
	menu_started = false
	menu_layer.current_menu = menu_layer.menu.SETTINGS

func _on_leave_button_pressed():
	menu_started = false
	if (GameManager.multiplayer_mode_enabled): #multiplayer disconnect
		if (multiplayer.is_server()): multiplayer.multiplayer_peer = null
		else: multiplayer.multiplayer_peer.disconnect_peer(1)
		GameManager.multiplayer_mode_enabled = false
		GameManager.host_mode_enabled = false
	GameManager.started_game = false
	game.end_level()
	menu_layer.current_menu = menu_layer.menu.MAIN

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()
