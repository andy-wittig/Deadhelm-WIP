extends Node

var random := RandomNumberGenerator.new()
var credits_active := false
var radio_active := false

@onready var music_selection = {
	"grasslands_track_1" : load("res://assets/music/never-ending.wav"),
	"grasslands_track_2" : load("res://assets/music/plains.mp3"),
	"grasslands_track_3" : load("res://assets/music/glorious_sunrise.mp3"),
	"desert_track_1" : load("res://assets/music/desert_trials.mp3"),
	"desert_track_2" : load("res://assets/music/factory.wav"),
	"cave_track_1" : load("res://assets/music/enter_deeper.mp3"),
	"title_screen_track" : load("res://assets/music/hopeful_awakening.wav"),
	"credits_track" : load("res://assets/music/credits.wav"),
	"bonus_track" : load("res://assets/music/bonus_track.mp3"),
	"radio_station" : load("res://assets/music/radio_station.mp3"),
}

@onready var music_player = $MusicPlayer

func credits_opened(active : bool):
	credits_active = active
	
func radio_opened(active : bool):
	radio_active = active

func _process(delta):
	if (GameManager.started_game):
		if (!radio_active):
			match GameManager.current_level:
				"level_grasslands_1":
					if (music_player.get_stream() != music_selection["grasslands_track_1"]):
						music_player.set_stream(music_selection["grasslands_track_1"])
				"level_grasslands_2":
					if (music_player.get_stream() != music_selection["grasslands_track_2"]):
						music_player.set_stream(music_selection["grasslands_track_2"])
				"level_grasslands_3":
					if (music_player.get_stream() != music_selection["grasslands_track_3"]):
						music_player.set_stream(music_selection["grasslands_track_3"])		
				"level_desert_1":
					if (music_player.get_stream() != music_selection["desert_track_1"]):
						music_player.set_stream(music_selection["desert_track_1"])
				"level_desert_2":
					if (music_player.get_stream() != music_selection["desert_track_2"]):
						music_player.set_stream(music_selection["desert_track_2"])
				"level_cave_1":
					if (music_player.get_stream() != music_selection["cave_track_1"]):
						music_player.set_stream(music_selection["cave_track_1"])
		else:
			if (music_player.get_stream() != music_selection["radio_station"]):
				music_player.set_stream(music_selection["radio_station"])
	elif (!credits_active):
		if (music_player.get_stream() != music_selection["title_screen_track"]):
			music_player.set_stream(music_selection["title_screen_track"])
	else:
		if (music_player.get_stream() != music_selection["credits_track"]):
			music_player.set_stream(music_selection["credits_track"])
		
	if (!music_player.playing):
		music_player.play()

#var choice = random.randi_range(1, 2)
	
