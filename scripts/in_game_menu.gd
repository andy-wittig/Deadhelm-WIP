extends Control

@onready var menu_layer = $"../.."

func _on_settings_button_pressed():
	menu_layer.current_menu = menu_layer.menu.SETTINGS

func _on_leave_button_pressed():
	pass # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	menu_layer.return_to_prev_menu()
