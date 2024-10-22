extends Control

@onready var menu_layer = $"../.."

var page_dict = {
	0 : ["res://assets/journal_pages/journal_page_1.txt",
	"res://assets/journal_pages/journal_page_2.txt"],
	1 : ["res://assets/journal_pages/journal_page_3.txt",
	"res://assets/journal_pages/journal_page_4.txt"],
}

var journal_length : int = page_dict.size() / 2
var journal_page := 1

var menu_started := false

func _ready():
	load_pages(page_dict[0][0], page_dict[0][1])
	
func load_pages(page_1: String, page_2: String):
	var read_page_1 = FileAccess.open(page_1, FileAccess.READ)
	var read_page_2 = FileAccess.open(page_2, FileAccess.READ)
	var page_content_1 := read_page_1.get_as_text()
	var page_content_2 := read_page_2.get_as_text()
	
	$VBoxContainer/Pages/JournalEntry.text = page_content_1
	$VBoxContainer/Pages/DescriptionEntry.text = page_content_2

func menu_opened():
	if (!menu_started):
		#$BackButton.grab_focus()
		menu_started = true

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()

func _on_prev_page_button_pressed():
	journal_page -= 1
	journal_page = clamp(journal_page, 0, journal_length)
	$VBoxContainer/PageNumber/LeftPageNumber.text = str((journal_page * 2) + 1)
	$VBoxContainer/PageNumber/RightPageNumber.text = str((journal_page * 2) + 2)
	load_pages(page_dict[journal_page][0], page_dict[journal_page][1])

func _on_next_page_button_pressed():
	journal_page += 1
	journal_page = clamp(journal_page, 0, journal_length) 
	$VBoxContainer/PageNumber/LeftPageNumber.text = str((journal_page * 2) + 1)
	$VBoxContainer/PageNumber/RightPageNumber.text = str((journal_page * 2) + 2)
	load_pages(page_dict[journal_page][0], page_dict[journal_page][1])
