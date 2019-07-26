class_name Tile extends Sprite

var _isBomb = false

func _init():
	texture = load("res://sprites/tile.png")
	modulate = Color("#ef5350")
	
func isBomb():
	return _isBomb
	
func setBomb():
	_isBomb = true