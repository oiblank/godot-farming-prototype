extends TileMap

###	TILE WIDTH AND PLAYER NODE
var TileBoundaries
var Player

###	TILE STATES
const Grass = 0
const Dug = 1
const Dug_Watered = 2
const Watered_Seed = 3
const Dry_Seed = 4
const Grown_Plant = 5
const Dead_Plant = 6
const Water_Source = 7

###	HOVER NODES
var Shovel_Hover
var Water_Hover
var Seed_Hover

###	PRELOADS
var Plant = preload("res://Scenes/Plant.tscn")
var Fence = preload("res://Scenes/Fence.tscn")

func _ready():
	set_process_input(true)
	###	LOAD TILEMAP SIZE
	TileBoundaries = get_used_cells()
	#
	Player = get_parent().get_node("Player_Character")
	###	HOVER NODES
	Shovel_Hover = get_node("Shovel_Hover")
	Water_Hover = get_node("Water_Hover")
	Seed_Hover = get_node("Seed_Hover")
	
	
func _input(event):
	###	ON MOUSE MOVEMENT
	if event.type == InputEvent.MOUSE_MOTION:
		###	GET OVERLAYING TILE
		var mouse_pos = get_global_mouse_pos()
		var tile_pos = world_to_map(mouse_pos)
		var tile = get_cellv(tile_pos)
		var distance = map_to_world(tile_pos).distance_to(Player.get_pos())
		###	IF IT IS IN TILEMAP AND IN RACH, CHECK FOR TOOL AND USE CORRESPONDING HOVER
		if tile_pos in TileBoundaries && distance < 35:
			if Player.Tool == "Water":
				Water_Hover.set_pos(map_to_world(tile_pos))
				Shovel_Hover.set_opacity(0)
				Water_Hover.set_opacity(1)
				Seed_Hover.set_opacity(0)
			elif Player.Tool == "Shovel":
				Shovel_Hover.set_pos(map_to_world(tile_pos))
				Shovel_Hover.set_opacity(1)
				Water_Hover.set_opacity(0)
				Seed_Hover.set_opacity(0)
			elif Player.Tool == "Seed":
				Seed_Hover.set_pos(map_to_world(tile_pos))
				Shovel_Hover.set_opacity(0)
				Water_Hover.set_opacity(0)
				Seed_Hover.set_opacity(1)
			else:
				Shovel_Hover.set_opacity(0)
				Water_Hover.set_opacity(0)
				Seed_Hover.set_opacity(0)
		else:
			Shovel_Hover.set_opacity(0)
			Water_Hover.set_opacity(0)
	###	ON MOUSE CLICK, GET TILE
	if Input.is_action_just_pressed("MOUSE_LEFT"):
		var mouse_pos = get_global_mouse_pos()
		var tile_pos = world_to_map(mouse_pos)
		var tile = get_cellv(tile_pos)
		var distance = map_to_world(tile_pos).distance_to(Player.get_pos())
		###	CHECK IF WE ARE NOT CLICKING ON A FENCE
		var is_free = true
		var Fences = get_node("/root/root/Fences").get_children()
		var i = 0
		for i in range(0, Fences.size()):
			var pos = Fences[i].get_global_pos()
			if world_to_map(pos) == tile_pos:
				is_free = false
				break
			else:
				is_free = true
		###	IF THE TILE IS IN TILEMAP AND IN REACH
		if tile_pos in TileBoundaries && distance < 35 && is_free:
			###	IF TILE IS GRASS OR DEAD PLANT AND WE DIG UP
			if tile == Grass && Player.Tool == "Shovel" || tile == Dead_Plant && Player.Tool == "Shovel" || tile == Dead_Plant && Player.Tool == "Hands":
				set_cellv(tile_pos, Dug)
				var timer = Timer.new()
				add_child(timer)
				timer.connect("timeout", self, "_on_Dug_timeout", [tile_pos, timer])
				timer.set_wait_time(3)
				timer.set_one_shot(true)
				timer.start()
			### IF TILE IS DUG UP AND WE ADD WATER
			elif tile == Dug && Player.Tool == "Water" && Player.Water_Resource >= 20:
				set_cellv(tile_pos, Dug_Watered)
				Player.Water_Resource -= 20
				var timer = Timer.new()
				add_child(timer)
				timer.connect("timeout", self, "_on_Water_Dug_timeout", [tile_pos, timer])
				timer.set_wait_time(3)
				timer.set_one_shot(true)
				timer.start()
			###	IF TILE IS DRY SEED AND WE ADD WATER
			elif tile == Dry_Seed && Player.Tool == "Water" && Player.Water_Resource >= 20:
				set_cellv(tile_pos, Watered_Seed)
				Player.Water_Resource -= 20
				var timer = Timer.new()
				add_child(timer)
				timer.connect("timeout", self, "_on_Water_Seed_timeout", [tile_pos, timer])
				timer.set_wait_time(3)
				timer.set_one_shot(true)
				timer.start()
			###	IF TILE IS DUG UP AND WE ADD SEED
			elif tile == Dug && Player.Tool == "Seed":
				set_cellv(tile_pos, Dry_Seed)
			###	IF TILE IS DUG UP AND WATERED AND WE ADD SEED
			elif tile == Dug_Watered && Player.Tool == "Seed":
				set_cellv(tile_pos, Watered_Seed)
				var timer = Timer.new()
				add_child(timer)
				timer.connect("timeout", self, "_on_Water_Seed_timeout", [tile_pos, timer])
				timer.set_wait_time(3)
				timer.set_one_shot(true)
				timer.start()
			###	IF TILE IS GROWN PLANT
			elif tile == Grown_Plant:
				set_cellv(tile_pos, Dug)
				var instanced_Plant = Plant.instance()
				get_parent().add_child(instanced_Plant)
				instanced_Plant.set_pos(map_to_world(tile_pos) + Vector2(8, 8))
				var timer = Timer.new()
				add_child(timer)
				timer.connect("timeout", self, "_on_Dug_timeout", [tile_pos, timer])
				timer.set_wait_time(3)
				timer.set_one_shot(true)
				timer.start()
			###	REFILL WATER CAN
			elif tile == Water_Source && Player.Tool == "Water":
				Player.Water_Resource += 40
				if Player.Water_Resource > 100:
					Player.Water_Resource = 100
			###	PLACE FENCE
			elif Player.Tool == "Fence":
				###	CHECK IF THERE IS NO PLAYER IN THE WAY, OR ANY OTHER TILE STATE
				if tile_pos == world_to_map(Player.get_global_pos()) || tile != Grass:
					pass
				else:
					var instanced_Fence = Fence.instance()
					get_parent().get_node("Fences").add_child(instanced_Fence)
					instanced_Fence.set_global_pos(map_to_world(tile_pos))
			
		
	
###	ON DUG TILE
func _on_Dug_timeout(tile_pos, timer):
	if get_cellv(tile_pos) == Dug:
		set_cellv(tile_pos, Grass)
	else:
		pass
	timer.queue_free()
###	ON WATERING THE DUG TILE
func _on_Water_Dug_timeout(tile_pos, timer):
	if get_cellv(tile_pos) == Dug_Watered:
		set_cellv(tile_pos, Dug)
		var timer2 = Timer.new()
		add_child(timer2)
		timer2.connect("timeout", self, "_on_Dug_timeout", [tile_pos, timer2])
		timer2.set_wait_time(3)
		timer2.set_one_shot(true)
		timer2.start()
	else:
		pass
	timer.queue_free()
###	ON WATERING A PLANTED SEED
func _on_Water_Seed_timeout(tile_pos, timer):
	if get_cellv(tile_pos) == Watered_Seed:
		set_cellv(tile_pos, Grown_Plant)
		var timer2 = Timer.new()
		add_child(timer2)
		timer2.connect("timeout", self, "_on_Growth_timeout", [tile_pos, timer2])
		timer2.set_wait_time(3)
		timer2.set_one_shot(true)
		timer2.start()
	else:
		pass
	timer.queue_free()
###	ON GROWN PLANT TO DEAD PLANT
func _on_Growth_timeout(tile_pos, timer):
	if get_cellv(tile_pos) == Grown_Plant:
		set_cellv(tile_pos, Dead_Plant)
	else:
		pass
	timer.queue_free()
###	ON OVERWATERED PLANT
func _on_Over_Watered_timeout(tile_pos, timer):
	if get_cellv(tile_pos) == Watered_Seed:
		set_cellv(tile_pos, Dead_Plant)
	else:
		pass
	timer.queue_free()