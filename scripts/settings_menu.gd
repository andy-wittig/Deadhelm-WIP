extends Control

var controls_list = [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"jump",
	"climb",
	"pickup",
	"cast_spell",
	"drop_item",
	"open_journal",
	"scroll_up",
	"scroll_down",
	"slot_1",
	"slot_2",
	"slot_3",
	"in-game_menu",
]

var menu_started := false

@onready var check_windowed = $VBoxContainer/SettingsTabs/DISPLAY/VBoxContainer/CheckWindowed
@onready var check_vsync = $VBoxContainer/SettingsTabs/DISPLAY/VBoxContainer/CheckVsync
@onready var remap_container = $VBoxContainer/SettingsTabs/CONTROLS/ScrollContainer/RemapContainer
@onready var mute_button = $VBoxContainer/SettingsTabs/SOUND/VBoxContainer/GridContainer/MuteButton
@onready var music_slider = $VBoxContainer/SettingsTabs/SOUND/VBoxContainer/GridContainer/MusicSlider
@onready var sfx_slider = $VBoxContainer/SettingsTabs/SOUND/VBoxContainer/GridContainer/SFXSlider
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var menu_layer = $"../.."

func _ready():
	if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED):
		check_windowed.button_pressed = true
	elif (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
		check_windowed.button_pressed = false
		
	if (DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED):
		check_vsync.button_pressed = true
	elif (DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED):
		check_vsync.button_pressed = false
		
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(MUSIC_BUS_ID))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SFX_BUS_ID))

	for action in controls_list:
		var label = Label.new()
		var button = custom_action.new()
		label.add_theme_font_override("font", load("res://assets/fonts/PixelOperator8.ttf"))
		button.add_theme_font_override("font", load("res://assets/fonts/PixelOperator8.ttf"))
		label.set("theme_override_font_sizes/font_size", 16)
		button.set("theme_override_font_sizes/font_size", 16)
		label.text = action.replace("_", " ")
		button.action = action
		remap_container.add_child(label)
		remap_container.add_child(button)
		
func menu_opened():
	if (!menu_started):
		$VBoxContainer/SettingsTabs.get_tab_bar().grab_focus()
		menu_started = true

#SOUND
func _on_mute_button_toggled(toggle):
	AudioServer.set_bus_mute(MUSIC_BUS_ID, toggle)
	AudioServer.set_bus_mute(SFX_BUS_ID, toggle)

func _on_music_slider_value_changed(value):
	mute_button.set_pressed_no_signal(false)
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)

func _on_sfx_slider_value_changed(value):
	mute_button.set_pressed_no_signal(false)
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()
	
#DISPLAY
func _on_check_cursor_toggled(toggled):
	if (toggled):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func _on_check_hud_toggled(toggled_on):
	GameManager.visible_hud = !GameManager.visible_hud
	get_tree().call_group("players", "toggle_hud")

func _on_check_windowed_toggled(toggled):
	if (toggled):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
func _on_check_vsync_toggled(toggled):
	if (toggled):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

#CONTROLS
class custom_action extends Button:
	var action: String
	
	func _init():
		toggle_mode = true
		
	func _ready():
		set_process_unhandled_input(false)
		update_action_text()
		
	func _toggled(button_pressed):
		set_process_unhandled_input(button_pressed)
		if (button_pressed):
			text = "awaiting input"
			release_focus()
		else:
			update_action_text()
			grab_focus()
			
	func _unhandled_input(event):
		if (event.pressed):
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			button_pressed = false
		
	func update_action_text():
		text = InputMap.action_get_events(action)[0].as_text().replace(" (Physical)", "")
