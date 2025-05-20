extends CanvasLayer

enum menu {
	MAIN,
	SETTINGS,
	CREDITS,
	INGAME,
	JOURNAL,
	TEXTBOX,
	STATS,
	HIDDEN,
	GAMEOVER,
}
var current_menu := menu.MAIN
var menu_started := false

@onready var menu_scenes = {
	"main_menu" : $MenuControl/MenuContainer,
	"title_background" : $MenuControl/TitleBackground,
	"settings_menu" : $MenuControl/settings_menu,
	"credits_menu" : $MenuControl/credits_menu,
	"in_game_menu" : $MenuControl/in_game_menu,
	"journal" : $MenuControl/JournalMenu,
	"textbox" : $MenuControl/textboxMenu,
	"stats_menu" : $MenuControl/stats_menu,
	"gameover_menu" : $MenuControl/gameover_menu,
}

@onready var continue_button = $MenuControl/MenuContainer/ContinueButton
@onready var confirm_container = $MenuControl/MenuContainer/ConfirmContainer

func _ready():
	continue_button.disabled = !FileAccess.file_exists("user://player_info.save")

func _process(_delta):
	continue_button.disabled = !FileAccess.file_exists("user://player_info.save")
	
	if (GameManager.started_game):
		if Input.is_action_just_pressed("in-game_menu"):
			if (current_menu == menu.HIDDEN):
				current_menu = menu.INGAME
			elif (current_menu == menu.INGAME || current_menu == menu.SETTINGS 
			|| current_menu == menu.JOURNAL || current_menu == menu.STATS || current_menu == menu.TEXTBOX):
				menu_scenes["in_game_menu"].menu_started = false
				menu_scenes["settings_menu"].menu_started = false
				menu_scenes["journal"].menu_started = false
				menu_scenes["stats_menu"].menu_started = false
				menu_scenes["textbox"].menu_started = false
				
				if (current_menu == menu.TEXTBOX) : menu_scenes["textbox"].stop_textbox()
				current_menu = menu.HIDDEN
				
		if Input.is_action_just_pressed("open_journal"):
			if (current_menu == menu.HIDDEN):
				$"../Audio/JournalOpened".play()
				current_menu = menu.JOURNAL
			elif (current_menu == menu.JOURNAL):
				$"../Audio/JournalClosed".play()
				current_menu = menu.HIDDEN
				$MenuControl/JournalMenu.menu_started = false
	
	match current_menu:
		menu.MAIN:
			for scene in menu_scenes:
				if (scene != "main_menu" && scene != "title_background"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					if (scene == "main_menu"):
						menu_opened()
		menu.SETTINGS:
			for scene in menu_scenes:
				if (scene != "settings_menu"):
					menu_scenes[scene].visible = false
				else:
					if (!GameManager.started_game):
						menu_scenes["title_background"].visible = true
					menu_scenes[scene].visible = true
					menu_scenes["settings_menu"].menu_opened()
					GameManager.access_ingame_menu = false
		menu.STATS:
			for scene in menu_scenes:
				if (scene != "stats_menu"):
					menu_scenes[scene].visible = false
				else:
					if (!GameManager.started_game):
						menu_scenes["title_background"].visible = true
					menu_scenes[scene].visible = true
					menu_scenes["stats_menu"].menu_opened()
					GameManager.access_ingame_menu = false
		menu.CREDITS:
			for scene in menu_scenes:
				if (scene != "credits_menu" && scene != "title_background"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes["credits_menu"].menu_opened()
		menu.INGAME:
			for scene in menu_scenes:
				if (scene != "in_game_menu"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes[scene].menu_opened()
					GameManager.access_ingame_menu = false
		menu.JOURNAL:
			for scene in menu_scenes:
				if (scene != "journal"):
					menu_scenes[scene].visible = false
				else:
					menu_scenes[scene].visible = true
					menu_scenes[scene].menu_opened()
					GameManager.access_ingame_menu = false
		menu.TEXTBOX:
			for scene in menu_scenes:
				if (scene != "textbox"):
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
		$MenuControl/MenuContainer/StartButton.grab_focus()
		menu_started = true
	
func return_to_prev_menu():
	if (GameManager.started_game):
		if (current_menu == menu.INGAME || current_menu == menu.JOURNAL || current_menu == menu.TEXTBOX):
			current_menu = menu.HIDDEN
		elif (current_menu == menu.SETTINGS):
			current_menu = menu.INGAME
		elif (current_menu == menu.STATS):
			current_menu = menu.INGAME
	else:
		current_menu = menu.MAIN
		
func open_textbox(file_path : String, headshot : Texture2D):
	if (current_menu == menu.HIDDEN):
		menu_scenes["textbox"].start_textbox(file_path, headshot)
		current_menu = menu.TEXTBOX
	elif (current_menu == menu.TEXTBOX):
		menu_scenes["textbox"].stop_textbox()
		current_menu = menu.HIDDEN

func _on_start_button_pressed():
	confirm_container.visible = !confirm_container.visible
	
func _on_continue_button_pressed():
	get_owner().continue_game()
	menu_started = false
	
func _on_settings_button_pressed():
	current_menu = menu.SETTINGS
	menu_started = false
	
func _on_stats_button_pressed():
	current_menu = menu.STATS
	menu_started = false
	
func _on_credits_button_pressed():
	current_menu = menu.CREDITS
	get_tree().call_group("audio_control", "credits_opened", true)
	menu_started = false
	
func _on_quit_button_pressed():
	get_tree().quit()

func _on_yes_button_pressed():
	confirm_container.visible = false
	get_owner().start_game()
	menu_started = false

func _on_no_button_pressed():
	confirm_container.visible = false
