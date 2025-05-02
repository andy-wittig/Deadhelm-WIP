extends StaticBody2D

class_name BreakableObject

@export var enemy_health := 25
@export var breaking_particles:  CPUParticles2D
@export var can_drop_coins := false
@export var coin_amount := 2

var MAX_HEALTH := enemy_health

var marked_for_death := false

signal enemy_was_hurt

func _process(delta):
	if (enemy_health <= 0):
		if (!marked_for_death):
			destroy_self()

func hurt_enemy(damage: int, direction: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	breaking_particles.emitting = true
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_parent().add_child(impact)
	impact.position = Vector2(position.x, position.y)
	impact.reset_physics_interpolation()
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
	
func destroy_self():
	marked_for_death = true
	
	if (can_drop_coins):
		for i in range(coin_amount):
			var coin = load("res://scenes/level_objects/coin.tscn").instantiate()
			coin.global_position = global_position
			get_tree().get_root().get_node("game/Level").add_child(coin)
	
	queue_free()
