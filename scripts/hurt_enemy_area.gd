extends Area2D

@export var damage: int
@export var attack_wait := 2.0
@export var destroy_time := 2
@export var knock_back := 0.0
@export var shape: CollisionShape2D

@onready var destroy_timer = $DestroyTimer

func _ready():
	$CollisionShape2D.set_shape(shape.get_shape())
	destroy_timer.start(destroy_time)

func _hurt_enemy_timer(enemy):
	if (enemy != null):
		for node in get_tree().get_nodes_in_group(enemy.name):
			if (node.is_in_group("destroy_timer")):
				node.call_deferred("queue_free")
			else:
				enemy.hurt_enemy(damage, global_position, knock_back)

func _on_destroy_timer_timeout():
	queue_free()

func _on_body_entered(body):
	var timer_started := false
	
	for node in get_tree().get_nodes_in_group(body.name):
		timer_started = true
	
	if (!timer_started):
		var enemy_damage_timer := Timer.new()
		add_child(enemy_damage_timer)
		enemy_damage_timer.add_to_group(body.name)
		enemy_damage_timer.wait_time = attack_wait
		enemy_damage_timer.timeout.connect(_hurt_enemy_timer.bind(body))
		enemy_damage_timer.start()
		body.hurt_enemy(damage, global_position, knock_back)

func _on_body_exited(body):
	for node in get_tree().get_nodes_in_group(body.name):
		node.add_to_group("destroy_timer")
