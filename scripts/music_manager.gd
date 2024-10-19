extends Node

var random := RandomNumberGenerator.new()

@onready var music_selection = {
	"grasslands_track_1" : load("res://assets/music/grasslands_track_1.mp3"),
	"grasslands_track_2" : load("res://assets/music/grasslands_track_2.mp3"),
	"desert_track_1" : load("res://assets/music/desert_track.mp3"),
	"desert_track_2" : load("res://assets/music/desert_track_2.mp3"),
	"cave_track_1" : load("res://assets/music/cave_track.mp3"),
	"title_screen_track" : load("res://assets/music/title_screen.mp3"),
}

@onready var music_player = $MusicPlayer

func _process(delta):
	if (GameManager.started_game):
		match GameManager.current_level:
			"level_grasslands_1":
				if (music_player.get_stream() != music_selection["grasslands_track_1"]):
					music_player.set_stream(music_selection["grasslands_track_1"])
			"level_grasslands_2":
				if (music_player.get_stream() != music_selection["grasslands_track_2"]):
					music_player.set_stream(music_selection["grasslands_track_2"])
			"level_grasslands_3":
				if (music_player.get_stream() != music_selection["desert_track_1"]):
					music_player.set_stream(music_selection["desert_track_1"])		
			"level_desert_1":
				if (music_player.get_stream() != music_selection["desert_track_2"]):
					music_player.set_stream(music_selection["desert_track_2"])
			"level_cave_1":
				if (music_player.get_stream() != music_selection["cave_track_1"]):
					music_player.set_stream(music_selection["cave_track_1"])
	else:
		if (music_player.get_stream() != music_selection["title_screen_track"]):
			music_player.set_stream(music_selection["title_screen_track"])
		
	if (!music_player.playing):
		music_player.play()

#var choice = random.randi_range(1, 2)
	
