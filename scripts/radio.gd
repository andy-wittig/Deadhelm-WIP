extends Area2D

@onready var radio_sprite = $RadioSprite
@onready var music_particles = $MusicParticles
@onready var boom_shader = $BackBufferCopy/BoomShader
@onready var radio_station_audio = $RadioStationAudio

var radio_active := false

func _process(delta):
	radio_sprite.material.set_shader_parameter("enabled", false)
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			radio_sprite.material.set_shader_parameter("enabled", true)
			if (Input.is_action_just_pressed("pickup")):
				radio_activate()
				
func radio_activate():
	radio_active = !radio_active
	music_particles.emitting = radio_active
	boom_shader.visible = radio_active
	get_tree().call_group("audio_control", "radio_opened", radio_active)
