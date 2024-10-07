extends Area2D

@onready var radio_sprite = $RadioSprite
@onready var music_particles = $MusicParticles
@onready var boom_shader = $BoomShader
@onready var radio_station_audio = $RadioStationAudio

func _process(delta):
	radio_sprite.material.set_shader_parameter("enabled", false)
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				radio_sprite.material.set_shader_parameter("enabled", true)
				if (Input.is_action_just_pressed("pickup")):
					radio_activate()
				
func radio_activate():
	music_particles.emitting = !music_particles.emitting
	boom_shader.visible = !boom_shader.visible
	if (radio_station_audio.playing):
		radio_station_audio.stop()
	else:
		radio_station_audio.play()
