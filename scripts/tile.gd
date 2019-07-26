class_name Tile extends Node2D

var _isBomb = false
var _revealed = false
var tiles:Array
var index:int
var width:int
var height:int
var count:int = -1
var sprite: Sprite
var label:Label
var que:Array

func _init(tiles, index, que, width, height):
	sprite = Sprite.new()
	sprite.texture = load("res://sprites/tile.png")
	sprite.modulate = Color("#ef5350")
	add_child(sprite)
	
	self.tiles = tiles
	self.index = index
	self.width = width
	self.height = height
	self.que = que
	
	var margin = width	
	var font = load("res://font/joystix.tres") as DynamicFont
	font.size = 35	
	
	label = Label.new()
	label.add_font_override("font", font)
	label.align = 1
	label.valign = 1
	label.margin_bottom = margin
	label.margin_top = -margin
	label.margin_left = -margin
	label.margin_right = margin
	label.rect_position = Vector2(-margin, -margin)
	label.text = "%s" % count
	label.visible = false
	label.name = "count"
	add_child(label)
	
func isBomb():
	return _isBomb
	
func setBomb():
	_isBomb = true

func setMarked():
	if count != -1:
		return
	label.text = "?"
	label.visible = true

func setRevealed():
	if _revealed:
		return
	var color: Color
	if _isBomb:
		color = Color("#F57F17")
	else:
		color = Color("#4DD0E1")
	sprite.modulate = color
	_revealed = true

func countBombs(cx, cy):
	if _isBomb || count != -1:
		return count
	count = 0
	for x in range(3):
		for y in range(3):
			var ny = (cy + y - 1)
			var nx = (cx + x - 1)
			if nx < 0 || nx >= width || ny < 0 || ny >= height: continue
			
			var i = ny * width + nx
			if i >= 0 && i < tiles.size() && tiles[i].isBomb():
				count += 1
	
	if count == 0:
		revealeNeighbors(cx, cy)
	elif count > 0:
		label.text = "%s" % count
		label.visible = true
	return count
	
func revealeNeighbors(cx, cy):
	for x in range(3):
		for y in range(3):
			if x == y: continue
			
			var ny = (cy + y - 1)
			var nx = (cx + x - 1)
			if nx < 0 || nx >= width || ny < 0 || ny >= height: continue
			
			var i = ny * width + nx
			if i < 0 && i >= tiles.size(): continue
			
			var tile = tiles[i] as Tile
			
			#Que up tile reveals since godot stack is really low, maybe a bug?
			if tile.isBomb(): return
			else:
				que.append({"tile":tile, "x": nx, "y": ny})
	return
	
func getSprite():
	return sprite