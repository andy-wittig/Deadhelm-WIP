extends Control

var server_port = 8080
var server_ip = "127.0.0.1"
var menu_started := false

@onready var menu_layer = $"../.."
@onready var game = $"../../.."

func menu_opened():
	if (!menu_started):
		$VBoxContainer/hostButton.grab_focus()
		menu_started = true

func _on_host_button_pressed():
	menu_started = false
	game.become_host(server_port)

func _on_join_button_pressed():
	menu_started = false
	game.join_game(server_ip, server_port)

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()

func _on_port_entry_text_changed(entered_text):
	server_port = int(entered_text)

func _on_ip_entry_text_changed(entered_text):
	server_ip = entered_text

func _on_name_entry_text_changed(entered_text):
	GameManager.username = entered_text
