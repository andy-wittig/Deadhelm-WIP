extends Node2D

@export_enum("left_facing", "right_facing") var facing_direction
@export var detection_range := 128

var attack_wait := false
var attack_direction

@onready var ray_cast = $RayCast2D
@onready var attack_timer = $AttackTimer
@onready var desecrater_sprite = $DesecraterSprite

func _ready():
	if (facing_direction == 0):
		ray_cast.target_position.x = -detection_range
		desecrater_sprite.flip_h = false
		attack_direction = Vector2(-1.0, 0.0)
	elif (facing_direction == 1):
		ray_cast.target_position.x = detection_range
		desecrater_sprite.flip_h = true
		attack_direction = Vector2(1.0, 0.0)

func _process(_delta):
	if (not attack_wait):
		if (ray_cast.is_colliding()):
			var body = ray_cast.get_collider()
			if (body.is_in_group("players")):
				if (multiplayer.is_server()):
					rpc("attack")
				elif (!GameManager.multiplayer_mode_enabled):
					attack()
				attack_timer.start()
				attack_wait = true

@rpc("call_local")
func attack():
	var blackhole = load("res://scenes/enemies/desecrater_blackhole.tscn").instantiate()
	blackhole.position = position
	blackhole.direction = attack_direction
	get_tree().get_root().get_node("game/Level").add_child(blackhole)

func _on_attack_timer_timeout():
	attack_wait = false
