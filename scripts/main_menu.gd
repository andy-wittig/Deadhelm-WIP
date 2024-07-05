extends CanvasLayer

enum menu {
	MAIN,
	MULTIPLAYER,
	SETTINGS,
	INGAME,
	HIDDEN
}
var current_menu := menu.MAIN

@onready var menu_control = $MenuControl
@onready var main_menu = $MenuControl/MenuContainer
@onready var settings_menu = $MenuControl/settings_menu
@onready var multiplayer_menu = $MenuControl/multiplayer_menu
@onready var in_game_menu = $MenuControl/in_game_menu

func _process(_delta):
	if (GameManager.started_game):
		if Input.is_action_just_pressed("in-game_menu"):
			if (current_menu == menu.HIDDEN):
				current_menu = menu.INGAME
			elif (current_menu == menu.INGAME || current_menu == menu.SETTINGS):
				current_menu = menu.HIDDEN
	
	match current_menu:
		menu.MAIN:
			menu_control.visible = true
			main_menu.visible = true
			settings_menu.visible = false
			multiplayer_menu.visible = false
			in_game_menu.visible = false
		menu.MULTIPLAYER:
			menu_control.visible = true
			main_menu.visible = false
			settings_menu.visible = false
			multiplayer_menu.visible = true
			in_game_menu.visible = false
		menu.SETTINGS:
			menu_control.visible = true
			main_menu.visible = false
			settings_menu.visible = true
			multiplayer_menu.visible = false
			in_game_menu.visible = false
		menu.INGAME:
			menu_control.visible = true
			main_menu.visible = false
			settings_menu.visible = false
			multiplayer_menu.visible = false
			in_game_menu.visible = true
		menu.HIDDEN:
			menu_control.visible = false
			main_menu.visible = false
			settings_menu.visible = false
			multiplayer_menu.visible = false
			in_game_menu.visible = false
			
func return_to_prev_menu():
	if (GameManager.started_game):
		if (current_menu == menu.INGAME):
			current_menu = menu.HIDDEN
		elif (current_menu == menu.SETTINGS):
			current_menu = menu.INGAME
	else:
		current_menu = menu.MAIN

func _on_start_button_pressed():
	get_owner().start_game()

func _on_multiplayer_button_pressed():
	current_menu = menu.MULTIPLAYER
	
func _on_settings_button_pressed():
	current_menu = menu.SETTINGS
	
func _on_quit_button_pressed():
	get_tree().quit()
