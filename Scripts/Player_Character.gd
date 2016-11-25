extends KinematicBody2D

var Tool = "Hands"
var label
var velocity = Vector2()
var MOVEMENT_SPEED = 35
var Water_Resource = 100

func _ready():
	set_process_input(true)
	set_fixed_process(true)
	label = get_node("Label")
	
func _input(event):
	###	TOOL DISPLAY
	if Tool == "Water":
		var format_string = "Tool:%s, %s"
		var actual_string = format_string % [Tool, Water_Resource]
		label.set_text(actual_string)
	else:
		label.set_text("Tool:%s" %Tool)
	###	TOOL SELECETION
	if Input.is_action_just_pressed("KEY_1"):
		Tool = "Hands"
	if Input.is_action_just_pressed("KEY_2"):
		Tool = "Shovel"
	if Input.is_action_just_pressed("KEY_3"):
		Tool = "Water"
	if Input.is_action_just_pressed("KEY_4"):
		Tool = "Seed"
	if Input.is_action_just_pressed("KEY_5"):
		Tool = "Fence"
	
func _fixed_process(delta):
	###	TOP-DOWN MOVEMENT
	if Input.is_action_pressed("KEY_LEFT"):
		velocity.x = -1
	elif Input.is_action_pressed("KEY_RIGH"):
		velocity.x = 1
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("KEY_UP"):
		velocity.y = -1
	elif Input.is_action_pressed("KEY_DOWN"):
		velocity.y = 1
	else:
		velocity.y = 0
	
	velocity = velocity.normalized()
	var motion = velocity * MOVEMENT_SPEED * delta
	move(motion)