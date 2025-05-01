extends Control

@onready var menu_layer = $"../.."

var menu_started := false

func menu_opened():
	if (!menu_started):
		$VBoxContainer/backButton.grab_focus()
		menu_started = true

func _on_back_button_pressed():
	menu_started = false
	get_tree().call_group("audio_control", "credits_opened", false)
	menu_layer.return_to_prev_menu()
