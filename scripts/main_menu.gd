extends CanvasLayer

enum menu {
	MAIN,
	MULTIPLAYER,
	SETTINGS,
	CREDITS,
	INGAME,
	HIDDEN,
	GAMEOVER,
}
var current_menu := menu.MAIN
var menu_started := false

@onready var menu_scenes = {
	"main_menu" : $MenuControl/MenuContainer,
	"title_background" : $MenuControl/TitleBackground,
	"settings_menu" : $MenuControl/settings_menu,
	"multiplayer_menu" : $MenuControl/multiplayer_menu,
	"credits_menu" : $MenuControl/credits_menu,
	"in_game_menu" : $MenuControl/in_game_menu,
	"gameover_menu" : $MenuControl/gameover_menu,
}

func _process(_delta):
	if (GameManager.started_game):
		if Input.is_action_just_pressed("in-game_menu"):
			if (current_menu == menu.HIDDEN):
				current_menu = menu.INGAME
			elif (current_menu == menu.INGAME || current_menu == menu.SETTINGS):
				current_menu = menu.HIDDEN
				$MenuControl/in_game_menu.menu_started = false
	
	match current_menu:
		menu.MAIN:
			for scene in menu_scenes:
				if (scene != "main_menu" && scene != "title_background"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					if (scene == "main_menu"):
						menu_opened()
		menu.MULTIPLAYER:
			for scene in menu_scenes:
				if (scene != "multiplayer_menu"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes[scene].menu_opened()
		menu.SETTINGS:
			for scene in menu_scenes:
				if (scene != "settings_menu"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes[scene].menu_opened()
					GameManager.access_ingame_menu = false
		menu.CREDITS:
			for scene in menu_scenes:
				if (scene != "credits_menu"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes[scene].menu_opened()
		menu.INGAME:
			for scene in menu_scenes:
				if (scene != "in_game_menu"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes[scene].menu_opened()
					GameManager.access_ingame_menu = false
		menu.HIDDEN:
			for scene in menu_scenes:
					menu_scenes[scene].visible = false
					GameManager.access_ingame_menu = true
		menu.GAMEOVER:
			for scene in menu_scenes:
				if (scene != "gameover_menu"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes[scene].menu_opened()

func menu_opened():
	if (!menu_started):
		$MenuControl/MenuContainer/startButton.grab_focus()
		menu_started = true
	
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
	menu_started = false

func _on_multiplayer_button_pressed():
	current_menu = menu.MULTIPLAYER
	menu_started = false
	
func _on_settings_button_pressed():
	current_menu = menu.SETTINGS
	menu_started = false
	
func _on_credits_button_pressed():
	current_menu = menu.CREDITS
	menu_started = false
	
func _on_quit_button_pressed():
	get_tree().quit()
