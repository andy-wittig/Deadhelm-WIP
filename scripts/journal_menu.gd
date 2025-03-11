extends Control

@onready var menu_layer = $"../.."

var spell_pages = [
	["res://assets/journal_pages/journal_lightning_spell.txt", true],
	["res://assets/journal_pages/journal_shield_spell.txt", true],
	["res://assets/journal_pages/journal_flame_spell.txt", true],
	["res://assets/journal_pages/journal_bow_spell.txt", true],
	["res://assets/journal_pages/journal_poison_bottle_spell.txt", true],
	["res://assets/journal_pages/journal_meteor_spell.txt", true],
	["res://assets/journal_pages/journal_phantasmal_push_spell.txt", true],
	["res://assets/journal_pages/journal_morning_star_spell.txt", true],
]

var enemy_pages = [
	["res://assets/journal_pages/journal_entry_blasphemer.txt", true],
	["res://assets/journal_pages/journal_description_blasphemer.txt", true],
	["res://assets/journal_pages/journal_entry_desecrator.txt", true],
	["res://assets/journal_pages/journal_description_desecrator.txt", true],
	["res://assets/journal_pages/journal_entry_impactor.txt", true],
	["res://assets/journal_pages/journal_description_impactor.txt", true],
	["res://assets/journal_pages/journal_entry_bombshell.txt", true],
	["res://assets/journal_pages/journal_description_bombshell.txt", true],
	["res://assets/journal_pages/journal_entry_bomb_frog.txt", true],
	["res://assets/journal_pages/journal_description_bomb_frog.txt", true],
	["res://assets/journal_pages/journal_entry_sentinel.txt", true],
	["res://assets/journal_pages/journal_description_sentinel.txt", true],
	["res://assets/journal_pages/journal_entry_fester.txt", true],
	["res://assets/journal_pages/journal_description_fester.txt", true],
	["res://assets/journal_pages/journal_entry_irritus.txt", true],
	["res://assets/journal_pages/journal_description_irritus.txt", true],
	["res://assets/journal_pages/journal_entry_golem.txt", true],
	["res://assets/journal_pages/journal_description_golem.txt", true],
	["res://assets/journal_pages/journal_entry_scorpion.txt", true],
	["res://assets/journal_pages/journal_description_scorpion.txt", true],
	["res://assets/journal_pages/journal_entry_snake.txt", true],
	["res://assets/journal_pages/journal_description_snake.txt", true],
]

var locked_page := "
[center]
[b][u]ENTRY LOCKED[/u][/b]

[img={width%}128{height%}]res://assets/sprites/UI/player_information/placeholder_lock.png[/img]

You'll have to keep searching to unlock this entry...
[/center]"

var chapter = {
	"Spell" : spell_pages,
	"Enemy" : enemy_pages,
}
var current_chapter := "Spell"
var journal_length : int = chapter[current_chapter].size()
var journal_page := 0
var menu_started := false

@onready var left_page = $VBoxContainer/Pages/LeftPage
@onready var right_page = $VBoxContainer/Pages/RighPage
@onready var left_page_number = $VBoxContainer/PageNumber/LeftPageNumber
@onready var right_page_number = $VBoxContainer/PageNumber/RightPageNumber
@onready var tab_bar = $VBoxContainer/TabBar

func _ready():
	load_pages(chapter[current_chapter][0][0], chapter[current_chapter][1][0])
			
func load_pages(page_1: String, page_2: String):
	if (chapter[current_chapter][journal_page][1]): #left page unlocked
		var read_page_1 = FileAccess.open(page_1, FileAccess.READ)
		var page_content_1 := read_page_1.get_as_text()
		left_page.text = page_content_1
	else:
		left_page.text = locked_page
	
	if (chapter[current_chapter][journal_page + 1][1]): #right page unlocked
		var read_page_2 = FileAccess.open(page_2, FileAccess.READ)
		var page_content_2 := read_page_2.get_as_text()
		
		right_page.text = page_content_2
	else:
		right_page.text = locked_page

func unlock_page(chapter_type : String, page_number : int):
	chapter[chapter_type][page_number][1] = true
	chapter[chapter_type][page_number + 1][1] = true

func menu_opened():
	if (!menu_started):
		$AnimationPlayer.play("fade_in")
		menu_started = true
		load_pages(chapter[current_chapter][0][0], chapter[current_chapter][1][0])

func _on_back_button_pressed():
	menu_started = false
	menu_layer.return_to_prev_menu()

func _on_prev_page_button_pressed():
	journal_page -= 2
	journal_page = clamp(journal_page, 0, journal_length - 2)
	left_page_number.text = str((journal_page) + 1)
	right_page_number.text = str((journal_page) + 2)
	load_pages(chapter[current_chapter][journal_page][0], chapter[current_chapter][journal_page + 1][0])

func _on_next_page_button_pressed():
	journal_page += 2
	journal_page = clamp(journal_page, 0, journal_length - 2) 
	left_page_number.text = str((journal_page) + 1)
	right_page_number.text = str((journal_page) + 2)
	load_pages(chapter[current_chapter][journal_page][0], chapter[current_chapter][journal_page + 1][0])

func _on_tab_bar_tab_changed(tab):
	current_chapter = chapter.keys()[tab_bar.current_tab]
	journal_page = 0
	journal_length = chapter[current_chapter].size()
	left_page_number.text = "1"
	right_page_number.text = "2"
	load_pages(chapter[current_chapter][0][0], chapter[current_chapter][1][0])
