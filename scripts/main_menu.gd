extends Control

enum menu {
	MAIN,
	MULTIPLAYER,
	SETTINGS,
}
var current_menu := menu.MAIN

@onready var main_menu = $MenuContainer
@onready var settings_menu = $settings_menu
@onready var multiplayer_menu = $multiplayer_menu

func _ready():
	settings_menu.visible = false
	multiplayer_menu.visible = false

func _process(_delta):
	match current_menu:
		menu.MAIN:
			main_menu.visible = true
			multiplayer_menu.visible = false
			settings_menu.visible = false
		menu.MULTIPLAYER:
			multiplayer_menu.visible = true
			main_menu.visible = false
			settings_menu.visible = false
		menu.SETTINGS:
			settings_menu.visible = true
			multiplayer_menu.visible = false
			main_menu.visible = false
			
func return_to_prev_menu():
	current_menu = menu.MAIN

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_multiplayer_button_pressed():
	current_menu = menu.MULTIPLAYER
	
func _on_settings_button_pressed():
	current_menu = menu.SETTINGS
	
func _on_quit_button_pressed():
	get_tree().quit()
