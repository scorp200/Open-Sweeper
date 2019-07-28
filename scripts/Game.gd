extends Node2D


var bombs = 30
var firstTouch = true
var tiles = []
var camera: Camera2D
var start_pos:Vector2
var zoom_step = Vector2(0.1, 0.1)
var zoom_max = Vector2(2, 2)
var zoom_min = Vector2(0.5, 0.5)
var Tile = load("res://scripts/tile.gd")
var que = []
var window: Vector2
#dragging
var dragging = false
var padding
#Scaling
var size
var half_size
var width_size
var height_size
var width:int = 20
var height:int = 20

func _ready():
	set_process(true)
	window = get_viewport_rect().size
	randomize()
	camera = $Camera2D

	#Create tiles
	for y in range(height):
		for x in range(width):
			var i = y * width + x
			var tile = Tile.new(tiles, i, que, width, height)
			if i == 0:
				size = tile.getSprite().texture.get_width()
				half_size = size / 2
				width_size = size * width
				height_size = size * height

			tile.set_position(Vector2(x * size, y * size))
			tile.name = "%s,%s" % [x, y]



			tiles.append(tile)
			$Tiles.add_child(tile)

	padding = size * 2
	camera.position = Vector2(width / 2 * size, height / 2 * size)

func _process(delta):
	#clear queued up tiles before anything else
	if que.size() > 0:
		for t in que:
			t.tile.setRevealed()
			t.tile.countBombs(t.x, t.y)
			que.erase(t)
		return

	if Input.is_action_just_released("MouseLeft"):
		#Click a tile
		if !dragging:
			var mouse = $Tiles.get_local_mouse_position()
			var x = floor((mouse.x + half_size) / size)
			var y = floor((mouse.y + half_size) / size)
			if x >= 0 && x < width && y >= 0 && y < height:
				var i = y * width + x
				#Place bombs randomly, excluding the first tile that was clicked on
				if firstTouch:
					for u in range(bombs):
						var index = randi()%tiles.size()
						while tiles[index].isBomb() || index == i:
							index = randi()%tiles.size()
						tiles[index].setBomb()
					firstTouch = false

				tiles[i].setRevealed()
				tiles[i].countBombs(x, y)

		dragging = false

	if Input.is_action_just_released("MouseRight"):
		#Mark tile as "?"
		if !dragging:
			var mouse = $Tiles.get_local_mouse_position()
			var x = floor((mouse.x + half_size) / size)
			var y = floor((mouse.y + half_size) / size)
			var i = y * width + x
			tiles[i].setMarked()



func snapCamera():
	var half_port = get_viewport_rect().size / 2
	var offset:float
	if (width_size < (half_port.x + padding) * camera.zoom.x):
		camera.position.x = width / 2 * size
	else:
		offset = (half_port.x - padding) * camera.zoom.x - half_size
		if camera.position.x < offset:
			camera.position.x = offset
		offset = (-half_port.x + padding) * camera.zoom.x + (width_size - half_size)
		if camera.position.x > offset:
			camera.position.x = offset
	if (height_size < (half_port.y + padding) * camera.zoom.y):
		camera.position.y = height / 2 * size
	else:
		offset = (half_port.y - padding) * camera.zoom.y - half_size
		if camera.position.y < offset:
			camera.position.y = offset
		offset = (-half_port.y + padding) * camera.zoom.y + (height_size - half_size)
		if camera.position.y > offset:
			camera.position.y = offset

func zoom_at_point(zoom):
	var old = camera.position
	var half_port = get_viewport_rect().size / 2
	var new_zoom = camera.zoom - zoom
	var offset = (get_global_mouse_position() - camera.position) * (camera.zoom - new_zoom) + old
	camera.position = offset
	camera.zoom = new_zoom

func _input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.is_pressed():
			match event.button_index:
				BUTTON_WHEEL_UP:
					if camera.zoom > zoom_min:
						zoom_at_point(zoom_step)
						snapCamera()
				BUTTON_WHEEL_DOWN:
					if camera.zoom < zoom_max:
						zoom_at_point(-zoom_step)
						snapCamera()
	elif event is InputEventMouseMotion && event.button_mask & BUTTON_MASK_LEFT:
		event = event as InputEventMouseMotion
		match event.button_mask:
			BUTTON_MASK_LEFT:
				dragging = true
				camera.position -= event.relative * camera.zoom
				snapCamera()
	elif event is InputEventMouse && event.is_action_released("MouseLeft") && event.button_index == BUTTON_LEFT:
		print("click")
		pass