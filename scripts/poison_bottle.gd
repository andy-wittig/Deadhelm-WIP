extends RigidBody2D

const THROWING_FORCE := 200

var player: CharacterBody2D

func get_sprite_path():
	return $PoisonBottleSprite.texture.resource_path
	
func _ready():
	$PoisonBottleSprite.rotation = player.spell_direction.angle()
	global_position = player.spell_spawn.global_position
	apply_central_impulse(player.spell_direction * THROWING_FORCE)

func _on_destroy_timer_timeout():
	var poison_cloud = load("res://scenes/vfx/poison_cloud.tscn").instantiate()
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	poison_cloud.position = position
	impact.position = position
	get_tree().get_root().get_node("game/Level").add_child(poison_cloud)
	get_tree().get_root().get_node("game/Level").add_child(impact)
	queue_free()
