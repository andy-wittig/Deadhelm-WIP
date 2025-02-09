extends Control

@onready var menu_layer = $"../.."
@onready var game = $"../../.."
@onready var item_list = $VBoxContainer/PanelContainer/ItemList

var runtime_array : Array[float]

var menu_started := false

func menu_opened():
	if (!menu_started):
		$VBoxContainer/BackButton.grab_focus()
		update_runtime_list()
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
		var line = runtime_file.get_float()
		runtime_array.append(line)
	
func update_runtime_list():
	item_list.clear()
	for runtime in runtime_array:
		item_list.add_item()
