extends StaticBody2D

const MAX_HEALTH := 25
var enemy_health := MAX_HEALTH
var marked_for_death := false

@onready var wood_particles = $CPUParticles2D

signal enemy_was_hurt

func _ready():
	pass

func _process(delta):
	if (enemy_health <= 0):
		if (!marked_for_death):
			destroy_self()

func hurt_enemy(damage: int, direction: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	wood_particles.emitting = true
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_parent().add_child(impact)
	impact.position = Vector2(position.x, position.y)
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
	
func destroy_self():
	#var effect = load("").instantiate()
	#effect.position = position
	#get_parent().add_child(effect)
	
	marked_for_death = true
	queue_free()
