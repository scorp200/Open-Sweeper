extends Node2D

var width = 20
var height = 20
var bombs = 30
var tiles = []
var camera: Camera2D
var start_pos:Vector2
var zoom_step = Vector2(0.1, 0.1)
var zoom_max = Vector2(2, 2)
var zoom_min = Vector2(0.5, 0.5)
var size: float
var Tile = load("res://scripts/tile.gd")
var que = []

#dragging
var dragging = false
var startDragging = false

func _ready():
	set_process(true)
	randomize()
	camera = $Tiles/Camera2D
	
	#Create tiles
	for y in range(height):
		for x in range(width):
			var i = y * width + x
			
			var tile = Tile.new(tiles, i, que, width, height)
			tile.set_position(Vector2(x * size, y * size))
			tile.name = "%s,%s" % [x, y]
			size = tile.getSprite().texture.get_width()
			
			tiles.append(tile)
			$Tiles.add_child(tile)
	
	#Place bombs	
	for i in range(bombs):
		var index = randi()%tiles.size()
		while tiles[index].isBomb():
			index = randi()%tiles.size()
		tiles[index].setBomb()
		

func _process(delta):
	#clear queued up tiles before anything else
	if que.size() > 0:
		for t in que:
			t.tile.setRevealed()
			t.tile.countBombs(t.x, t.y)
			que.erase(t)
		return
	
	#Tile input
	if Input.is_action_just_released("MouseLeft") && !dragging:
		var mouse = $Tiles.get_local_mouse_position()
		var x = floor((mouse.x + size / 2) / size)
		var y = floor((mouse.y + size / 2) / size)
		var i = y * width + x
		tiles[i].setRevealed()
		tiles[i].countBombs(x, y)
	if Input.is_action_just_released("MouseRight") && !dragging:
		var mouse = $Tiles.get_local_mouse_position()
		var x = floor((mouse.x + size / 2) / size)
		var y = floor((mouse.y + size / 2) / size)
		var i = y * width + x
		tiles[i].setMarked()
	
	#Dragging
	if Input.is_action_pressed("MouseLeft"):
		if !startDragging:
			start_pos = camera.position + camera.get_local_mouse_position()
		startDragging = true
		if abs(start_pos.distance_to(camera.position + camera.get_local_mouse_position())) > 0.1:
			dragging = true
	elif Input.is_action_just_released("MouseLeft"):
		dragging = false
		startDragging = false
	if dragging:
		camera.set_position(start_pos - camera.get_local_mouse_position())
	
func _input(event):
	if event.is_pressed() && event is InputEventMouse:
		if event.button_index == BUTTON_WHEEL_UP && camera.zoom > zoom_min:
			camera.set_zoom(camera.zoom - zoom_step)
		elif event.button_index == BUTTON_WHEEL_DOWN && camera.zoom < zoom_max:
			camera.set_zoom(camera.zoom + zoom_step)