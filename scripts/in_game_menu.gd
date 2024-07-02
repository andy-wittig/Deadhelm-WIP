extends Control

@onready var settings_menu = $settings_menu
@onready var menu_options = $MenuOptions

func return_to_prev_menu():
	menu_options.visible = true
	settings_menu.visible = false

func _on_settings_button_pressed():
	menu_options.visible = false
	settings_menu.visible = true 

func _on_leave_button_pressed():
	pass # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	visible = false
