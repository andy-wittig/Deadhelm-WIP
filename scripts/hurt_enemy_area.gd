extends Area2D

@export var damage: int
@export var attack_wait := 2.0
@export var knock_back := 0.0
@export var shape: CollisionShape2D

func _ready():
	$CollisionShape2D.set_shape(shape.get_shape())

func _hurt_enemy_timer(enemy):
	if (enemy != null):
		for timer in get_tree().get_nodes_in_group(enemy.name + str(get_instance_id())):
			if (timer.is_in_group("destroy_timer")):
				timer.queue_free()
			else:
				enemy.hurt_enemy(damage, global_position, knock_back)

func _on_body_entered(body):
	if (body.is_in_group("enemies")):
		var timer_id = body.name + str(get_instance_id()) #links enemy name with hurt enemy area id
		if (get_tree().get_nodes_in_group(timer_id).size() == 0):
			var enemy_damage_timer := Timer.new()
			add_child(enemy_damage_timer)
			enemy_damage_timer.add_to_group(timer_id)
			enemy_damage_timer.wait_time = attack_wait
			enemy_damage_timer.one_shot = false
			enemy_damage_timer.timeout.connect(_hurt_enemy_timer.bind(body))
			enemy_damage_timer.start()
			body.hurt_enemy(damage, global_position, knock_back)
		else:
			for timer in get_tree().get_nodes_in_group(timer_id):
				timer.remove_from_group("destroy_timer")

func _on_body_exited(body):
	for timer in get_tree().get_nodes_in_group(body.name + str(get_instance_id())):
		timer.add_to_group("destroy_timer")
