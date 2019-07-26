class_name Tile extends Node2D

var _isBomb = false
var _revealed = false
var tiles:Array
var index:int
var width:int
var count:int = -1
var sprite: Sprite

const pattern = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
func _init(tiles, index, width):
	sprite = Sprite.new()
	sprite.texture = load("res://sprites/tile.png")
	sprite.modulate = Color("#ef5350")
	add_child(sprite)
	
	self.tiles = tiles
	self.index = index
	self.width = width
	
	var text = Label.new()
	var font = load("res://font/joystix.tres") as DynamicFont
	font.size = 35
	text.add_font_override("font", font)
	text.align = 1
	text.valign = 1
	var margin = width
	text.margin_bottom = margin
	text.margin_top = -margin
	text.margin_left = -margin
	text.margin_right = margin
	text.rect_position = Vector2(-margin, -margin)
	text.text = "%s" % count
	text.visible = false
	text.name = "count"
	add_child(text)
	
func isBomb():
	return _isBomb
	
func setBomb():
	_isBomb = true

func setMarked():
	if count != -1:
		return
	$count.text = "?"
	$count.visible = true

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
			var i = ny * width + nx
			if i >= 0 && i < tiles.size() && tiles[i].isBomb():
				count += 1
	if count == 0:
		revealeNeighbors(cx, cy)
	if count > 0:
		$count.text = "%s" % count
		$count.visible = true
	return count
	
func revealeNeighbors(cx, cy):
	for p in pattern:
		var ny = (cy + p.y)
		var nx = (cx + p.x)
		var i = ny * width + nx
		if i >= 0 && i < tiles.size() && !tiles[i].isBomb():
			tiles[i].setRevealed()
			if tiles[i].countBombs(nx, ny) != 0 && count > 0:
				return
			
	return true
	
func getSprite():
	return sprite