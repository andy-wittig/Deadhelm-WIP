extends Node2D

@export var attack_wait := 1.0
@export var facing_dir := 1

@onready var attack_timer = $AttackTimer
@onready var sprite = $Sprite2D
@onready var particles = $CPUParticles2D

func _ready():
	attack_timer.start(attack_wait)
	particles.direction.x = facing_dir
	sprite.scale.x *= -facing_dir
	
func _on_attack_timer_timeout():
	var impactor_ball = load("res://scenes/enemies/impactor_ball.tscn").instantiate()
	impactor_ball.global_position = Vector2(global_position.x, global_position.y - 6)
	impactor_ball.dir = facing_dir
	get_tree().get_root().get_node("game/Level").add_child(impactor_ball)
	particles.emitting = true
