extends Control

@onready var menu_layer = $"../.."

var page_dict = {
	0 : ["res://assets/journal_pages/journal_entry_blasphemer.txt",
	"res://assets/journal_pages/journal_description_blasphemer.txt", true],
	1 : ["res://assets/journal_pages/journal_entry_desecrator.txt",
	"res://assets/journal_pages/journal_description_desecrator.txt", true],
	2 : ["res://assets/journal_pages/journal_entry_bombshell.txt",
	"res://assets/journal_pages/journal_description_bombshell.txt", true],
	3 : ["res://assets/journal_pages/journal_entry_bomb_frog.txt",
	"res://assets/journal_pages/journal_description_bomb_frog.txt", true],
	4 : ["res://assets/journal_pages/journal_entry_sentinel.txt",
	"res://assets/journal_pages/journal_description_sentinel.txt", true],
	5 : ["res://assets/journal_pages/journal_entry_fester.txt",
	"res://assets/journal_pages/journal_description_fester.txt", true],
	6 : ["res://assets/journal_pages/journal_entry_irritus.txt",
	"res://assets/journal_pages/journal_description_irritus.txt", true],
	7 : ["res://assets/journal_pages/journal_entry_golem.txt",
	"res://assets/journal_pages/journal_description_golem.txt", true],
	8 : ["res://assets/journal_pages/journal_entry_scorpion.txt",
	"res://assets/journal_pages/journal_description_scorpion.txt", true],
	9 : ["res://assets/journal_pages/journal_entry_snake.txt",
	"res://assets/journal_pages/journal_description_snake.txt", true],
}

var locked_page := "
[center]
[b][u]ENTRY LOCKED[/u][/b]

[img={width%}128{height%}]res://assets/sprites/UI/player_information/placeholder_lock.png[/img]

Discover and defeat new enemies to unlock this page.
[/center]
"
var journal_length : int = page_dict.size()
var journal_page := 0
var menu_started := false

func _ready():
	load_pages(page_dict[0][0], page_dict[0][1])
	
func load_pages(page_1: String, page_2: String):
	if (page_dict[journal_page][2]): #pages are unlocked
		var read_page_1 = FileAccess.open(page_1, FileAccess.READ)
		var read_page_2 = FileAccess.open(page_2, FileAccess.READ)
		var page_content_1 := read_page_1.get_as_text()
		var page_content_2 := read_page_2.get_as_text()
		
		$VBoxContainer/Pages/JournalEntry.text = page_content_1
		$VBoxContainer/Pages/DescriptionEntry.text = page_content_2
	else:
		$VBoxContainer/Pages/JournalEntry.text = locked_page
		$VBoxContainer/Pages/DescriptionEntry.text = locked_page

func unlock_page(page_number : int):
	page_dict[page_number][2] = true

func menu_opened():
	if (!menu_started):
		#$BackButton.grab_focus()
		menu_started = true
		load_pages(page_dict[0][0], page_dict[0][1])

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()

func _on_prev_page_button_pressed():
	journal_page -= 1
	journal_page = clamp(journal_page, 0, journal_length - 1)
	$VBoxContainer/PageNumber/LeftPageNumber.text = str((journal_page * 2) + 1)
	$VBoxContainer/PageNumber/RightPageNumber.text = str((journal_page * 2) + 2)
	load_pages(page_dict[journal_page][0], page_dict[journal_page][1])

func _on_next_page_button_pressed():
	journal_page += 1
	journal_page = clamp(journal_page, 0, journal_length - 1) 
	$VBoxContainer/PageNumber/LeftPageNumber.text = str((journal_page * 2) + 1)
	$VBoxContainer/PageNumber/RightPageNumber.text = str((journal_page * 2) + 2)
	load_pages(page_dict[journal_page][0], page_dict[journal_page][1])
