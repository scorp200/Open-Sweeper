extends Node2D

var width = 20
var height = 20
var tiles = []
var camera: Camera2D
var start_pos:Vector2
var zoom_step = Vector2(0.1, 0.1)
var zoom_max = Vector2(2, 2)
var zoom_min = Vector2(0.5, 0.5)
var size: float
var Tile = load("res://scripts/tile.gd")

#dragging
var dragging = false
var startDragging = false

func _ready():
	camera = $Tiles/Camera2D
	for y in range(height):
		for x in range(width):
			var i = y * width + x
			var sprite = Tile.new()
			size = sprite.texture.get_width()
			tiles.append(sprite)
			$Tiles.add_child(sprite)
			sprite.set_position(Vector2(x * size, y * size))
			
	for i in range(15):
		var index = randi()%tiles.size()
		while tiles[index].isBomb():
			index = randi()%tiles.size()
		tiles[index].setBomb()
		

func _process(delta):
	if Input.action_press("WheelUp"):
		camera.set_zoom(camera.zoom + Vector2(10, 10))
	if Input.is_action_just_released("MouseLeft") && !dragging:
		var x = floor(($Tiles.get_local_mouse_position().x + size / 2) / size)
		var y = floor(($Tiles.get_local_mouse_position().y + size / 2) / size)
		var i = y * width + x
		var color: Color
		if tiles[i].isBomb():
			color = Color("#F57F17")
		else:
			color = Color("#4DD0E1")
		tiles[i].modulate = color
		
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
	if event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP && camera.zoom > zoom_min:
			camera.set_zoom(camera.zoom - zoom_step)
		elif event.button_index == BUTTON_WHEEL_DOWN && camera.zoom < zoom_max:
			camera.set_zoom(camera.zoom + zoom_step)