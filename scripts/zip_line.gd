extends Area2D

@export var zipline_path : Path2D

var zipline_line: Line2D
var zipline_follow: PathFollow2D
var player: CharacterBody2D
var zipline_active := false

func _ready():
	zipline_follow = PathFollow2D.new()
	zipline_line = Line2D.new()
	
	self.add_child(zipline_path)
	zipline_path = get_node("Path2D")
	zipline_path.add_child(zipline_line)
	zipline_path.add_child(zipline_follow)
	
	#Line Setup
	zipline_line.default_color = Color("4d3533")  
	zipline_line.width = 1
	zipline_line.joint_mode = Line2D.LINE_JOINT_ROUND
	var points = zipline_path.curve.get_baked_points()
	zipline_line.points = points
	
	#Path Follow Setup
	zipline_follow.loop = false
	zipline_follow.rotates = false

func _process(delta):
	if (!zipline_active):
		for body in get_overlapping_bodies():
			if (body.is_in_group("players")):
				if (!GameManager.multiplayer_mode_enabled ||
				body.player_id == multiplayer.get_unique_id()):
					if (Input.is_action_just_pressed("move_up") || 
					Input.is_action_just_pressed("move_down")):
						body.state = body.state_type.ZIPLINE
						zipline_active = true
						player = body
	else:
		zipline_follow.progress += player.ZIPLINE_SPEED * delta
		player.global_position = zipline_follow.global_position
		
		if (zipline_follow.progress_ratio == 1.0 ||
		Input.is_action_just_pressed("move_up") || 
		Input.is_action_just_pressed("move_down")):
			player.state = player.state_type.MOVING
			zipline_follow.progress = 0
			zipline_active = false
