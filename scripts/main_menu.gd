extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_multiplayer_button_pressed():
	var scene = preload("res://scenes/multiplayer_menu.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	
func _on_quit_button_pressed():
	get_tree().quit()
