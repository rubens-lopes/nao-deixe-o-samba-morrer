# adapted with thanks from code by GDQuest
# http://gdquest.com/
# Usage: Attach this script to a Node2D and add as a child of the node you want to
# 		draw vectors
extends Node2D

var colors = {
	'WHITE': Color(.8, .8, .8, 0.2),
	'BLUE': Color(.216, .474, .702, 0.2),
	'RED': Color(1.0, .329, .298, 0.7),
	'YELLOW': Color(.867, .91, .247),
	'GREEN': Color(.054, .718, .247, 0.7)
}

const WIDTH = 7
const ARROW_SIZE = 10
const VIEW_TOGGLE = "ui_focus_next"
var parent = null

func _ready():
	parent = get_parent()

func _process(delta):
	global_rotation = 0
	update()

func _draw():
	draw_arrow(parent.velocity, Vector2(), 0.5, 'RED')

func draw_arrow(vector, pos, size, color):
	color = colors[color]
	if vector.length() == 0:
		return
	draw_line(pos * scale, vector * size, color, WIDTH)
	var dir = vector.normalized()
	draw_triangle(vector * size, dir, ARROW_SIZE, color)
	draw_circle(pos, 3, color)

func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))

