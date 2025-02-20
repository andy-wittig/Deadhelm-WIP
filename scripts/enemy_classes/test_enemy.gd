extends BaseEnemy

@onready var hurt_player_area = $HurtPlayerArea

func _ready():
	super()
	hurt_player_area.active = false
	hurt_player_area.attack_wait = attack_timer_wait

func _physics_process(delta):
	super(delta)
	
	if (direction > 0):
		hurt_player_area.position = Vector2(20, 0)
	elif (direction < 0):
		hurt_player_area.position = Vector2(0, 0)
		
func start_enemy_attack():
	if (!attack_started):
		enemy_sprite.play("attack")
		if (enemy_sprite.frame == 3 && player != null):
			hurt_player_area.active = true
			attack_timer.start(attack_timer_wait)
			attack_started = true
		
	velocity.x = 0
	
func attack_finished():
	if (attack_started):
		enemy_sprite.play("idle")
		hurt_player_area.active = false
	
