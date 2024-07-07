extends Control

@onready var menu_layer = $"../.."

func _on_back_button_pressed():
	menu_layer.return_to_prev_menu()
