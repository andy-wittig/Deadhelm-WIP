extends Node2D

@export var detection_range := 128

var attack_wait := false
var attack_direction : Vector2

@onready var ray_cast = $RayCast2D
@onready var attack_timer = $AttackTimer
@onready var desecrater_sprite = $DesecraterSprite

func _ready():
	get_tree().call_group("unlock_enemy", "unlock_page", 1)

func _process(_delta):
	if (not attack_wait):
		if (ray_cast.is_colliding()):
			var body = ray_cast.get_collider()
			if (body.is_in_group("players")):
				attack()
				attack_timer.start()
				attack_wait = true

func attack():
	$CPUParticles2D.emitting = true
	$FireAudio.play()
	
	var blackhole = load("res://scenes/enemies/desecrater_blackhole.tscn").instantiate()
	blackhole.global_position = global_position
	blackhole.direction = Vector2(-scale.x, 0)
	get_tree().get_root().get_node("game/Level").add_child(blackhole)

func _on_attack_timer_timeout():
	attack_wait = false
