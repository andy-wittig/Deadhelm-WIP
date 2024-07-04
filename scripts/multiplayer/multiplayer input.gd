extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction
var climb_direction
var username := ""

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		
	input_direction = Input.get_axis("move_left", "move_right")
	climb_direction = Input.get_axis("move_up", "move_down")
	
	username = GameManager.username

func _physics_process(delta):
	if (not get_parent().is_in_chat):
		input_direction = Input.get_axis("move_left", "move_right")
		climb_direction = Input.get_axis("move_up", "move_down")

func _process(delta):
	if (Input.is_action_just_pressed("jump") && not get_parent().is_in_chat):
		jump.rpc()

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.jumped = true
