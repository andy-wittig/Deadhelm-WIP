extends Control

var server_port = 8080
var server_ip = "127.0.0.1"

func _on_host_button_pressed():
	MultiplayerManager.become_host(server_port)

func _on_join_button_pressed():
	MultiplayerManager.join_game(server_ip, server_port)

func _on_back_button_pressed():
	get_parent().return_to_prev_menu()

func _on_port_entry_text_changed(new_text):
	server_port = int(new_text)

func _on_ip_entry_text_changed(new_text):
	server_ip = new_text

func _on_name_entry_text_changed(new_text):
	MultiplayerManager.username = new_text
