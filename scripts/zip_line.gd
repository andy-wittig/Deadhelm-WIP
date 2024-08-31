extends Node2D

@export var zipline_path : Path2D

var zipline_line: Line2D
var zipline_follow: PathFollow2D
var player: CharacterBody2D
var zipline_active := false

@onready var sparks_particle = $SparksParticle

func _ready():
	zipline_follow = PathFollow2D.new()
	zipline_line = Line2D.new()
	
	zipline_path.add_child(zipline_line)
	zipline_path.add_child(zipline_follow)
	
	#Line Setup
	zipline_line.texture = load("res://assets/sprites/vfx/zipline_rope_texture.png")
	zipline_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	zipline_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	zipline_line.width = 3
	zipline_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	zipline_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	var points = zipline_path.curve.get_baked_points()
	zipline_line.points = points
	
	#zipline collision
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment
		$LineCollisionShapes.add_child(new_shape)
	
	#Path Follow Setup
	zipline_follow.loop = false
	zipline_follow.rotates = false

func _process(delta):
	if (!zipline_active):
		sparks_particle.emitting = false
		
		for area in $LineCollisionShapes.get_overlapping_areas():
			if (area.is_in_group("players")):
				var body = area.get_parent()
				if (!GameManager.multiplayer_mode_enabled ||
				body.player_id == multiplayer.get_unique_id()):
					if (Input.is_action_just_pressed("pickup")):
						body.state = body.state_type.ZIPLINE
						zipline_active = true
						player = body
						
						var offset = zipline_path.curve.get_closest_offset(zipline_path.to_local(player.global_position))
						zipline_follow.progress = offset
	else:
		zipline_follow.progress += player.ZIPLINE_SPEED * delta
		player.global_position = zipline_follow.global_position
		sparks_particle.emitting = true
		sparks_particle.global_position = zipline_follow.global_position
		
		if (zipline_follow.progress_ratio == 1.0 ||
		Input.is_action_just_pressed("move_up") || 
		Input.is_action_just_pressed("move_down") ||
		Input.is_action_just_pressed("pickup")):
			player.state = player.state_type.MOVING
			zipline_follow.progress = 0
			zipline_active = false
