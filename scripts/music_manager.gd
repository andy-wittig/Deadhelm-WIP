extends Node

@onready var title_track = $TitleTrack
@onready var level_track_1 = $LevelTrack1
@onready var level_track_2 = $LevelTrack2

func _process(delta):
	if (GameManager.started_game):
		for current_level in get_tree().get_root().get_node("game/Level").get_children():
			if (current_level.get_name() == "level_1"):
				if (not level_track_1.playing):
					stop_music()
					level_track_1.play()
			elif (current_level.get_name() == "level_2"):
				if (not level_track_2.playing):
					stop_music()
					level_track_2.play()
	elif (not title_track.playing):
		stop_music()
		title_track.play()
		
func stop_music():
	for track in get_children():
		track.stop()
