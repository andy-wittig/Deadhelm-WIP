extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_multiplayer_button_pressed():
	var multiplayer_scene = preload("res://scenes/multiplayer_menu.tscn").instantiate()
	multiplayer_scene.grab_focus()
	add_child(multiplayer_scene)
	
func _on_settings_button_pressed():
	var settings_scene = preload("res://scenes/settings_menu.tscn").instantiate()
	settings_scene.grab_focus()
	add_child(settings_scene)
	
func _on_quit_button_pressed():
	get_tree().quit()
