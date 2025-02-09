extends Control

@onready var menu_layer = $"../.."
@onready var game = $"../../.."
@onready var item_list = $VBoxContainer/ItemList
@onready var enabled_button = $VBoxContainer/PanelContainer/HBoxContainer/EnabledButton

var runtime_array : Array
var menu_started := false

func _ready():
	enabled_button.button_pressed = GameManager.show_runtime

func menu_opened():
	if (!menu_started):
		print ("hey")
		load_runtime()
		update_runtime_list()
		$VBoxContainer/PanelContainer/HBoxContainer/EnabledButton.grab_focus()
		menu_started = true
	
func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()

func load_runtime():
	if not FileAccess.file_exists("user://runtime.save"):
		return
		
	var runtime_file = FileAccess.open("user://runtime.save", FileAccess.READ)
	
	runtime_array.clear()
	
	while (!runtime_file.eof_reached()):
		runtime_array.append(runtime_file.get_line())
		
	runtime_array.pop_back()
	runtime_array.reverse()
	
	runtime_file.close()
	
func update_runtime_list():
	item_list.clear()
	for runtime in runtime_array:
		var float_run_time = float(runtime)
		var time = floori(float_run_time)
		var hours = (time / 3600) % 24
		var minutes = (time / 60) % 60
		var seconds = (time) % 60
		var fractional_seconds = int(fmod(snapped(float_run_time, 0.01), 1) * 100)
		var converted_runtime = str("%02d:%02d:%02d.%02d" % [hours, minutes, seconds, fractional_seconds])
		item_list.add_item(converted_runtime, load("res://assets/sprites/UI/text_speedrun.png"), true)

func _on_enabled_button_toggled(toggled_on):
	GameManager.show_runtime = toggled_on
	
func _on_sort_button_pressed():
	runtime_array.sort()
	runtime_array.reverse()
	update_runtime_list()

func _on_delete_button_pressed():
	if not FileAccess.file_exists("user://runtime.save"):
		return
	var runtime_file = FileAccess.open("user://runtime.save", FileAccess.WRITE)
	runtime_file.close()
	runtime_array.clear()
	update_runtime_list()
