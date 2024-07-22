extends Control

@onready var menu_layer = $"../.."
	
func _on_return_button_pressed():
	menu_layer.return_to_prev_menu()
