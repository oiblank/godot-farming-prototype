extends Sprite

var Player

func _ready():
	set_fixed_process(true)
	Player = get_node("/root/root/Player_Character")
	
func _fixed_process(delta):
	###	WHEN IN REACH, FOLLOW THE PLAYER
	var Player_Pos = Player.get_global_pos()
	var distance = get_global_pos().distance_to(Player_Pos)
	if distance < 30:
		var direction = (Player_Pos - get_global_pos()).normalized()
		var motion = direction * 30 * delta
		set_pos(get_pos() + motion)
	###	ON COLLISION WITH PLAYER FREE SELF, TODO:add resource to player inventory
func _on_Player_Check_body_enter( body ):
	if body.get_name() == "Player_Character":
		self.queue_free()
