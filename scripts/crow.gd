extends Area2D

@export var roost_locations : Array[Vector2]

@onready var crow_animated_sprite = $CrowAnimatedSprite

var roost_point : Vector2
var flying := false
const FLY_SPEED := 60

func _ready():
	roost_locations.push_front(global_position)

func _process(delta):
	if (flying):
		crow_animated_sprite.play("fly")
		global_position += (roost_point - global_position).normalized() * delta * FLY_SPEED
		if (abs(global_position - roost_point) <= Vector2(0.1, 0.1)):
			global_position = roost_point
			$AnimationPlayer.play("RESET")
			crow_animated_sprite.play("idle")
			flying = false

func _on_body_entered(body):
	if (body.is_in_group("players")):
		if (!flying):
			var i = randi_range(0, roost_locations.size() - 1)
			roost_point = roost_locations[i]
			$AnimationPlayer.play("bounce")
			flying = true
			
			if (sign(global_position.x - roost_point.x) > 0):
				scale.x = 1
			else:
				scale.x = -1
	
