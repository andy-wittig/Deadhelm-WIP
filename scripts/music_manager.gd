extends Node

@onready var title_screen_music = $TitleScreenMusic
@onready var level_music = $LevelMusic

func _ready():
	title_screen_music.play()

func _process(delta):
	if (GameManager.started_game):
		if (not level_music.playing):
			title_screen_music.stop()
			level_music.play()
