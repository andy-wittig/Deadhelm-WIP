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
	
func _on_stats_button_pressed():
	menu_started = false
	menu_layer.current_menu = menu_layer.menu.STATS

func _on_leave_button_pressed():
	get_tree().call_group("players", "save_player_info")
	GameManager.started_game = false
	menu_started = false
	menu_layer.current_menu = menu_layer.menu.MAIN
	game.end_level()

func _on_quit_button_pressed():
	get_tree().call_group("players", "save_player_info")
	get_tree().quit()

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()
