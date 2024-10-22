extends Control

@onready var menu_layer = $"../.."

var menu_started := false

func menu_opened():
	if (!menu_started):
		#$BackButton.grab_focus()
		menu_started = true

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()
