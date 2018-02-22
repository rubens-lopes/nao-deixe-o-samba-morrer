extends Node2D

export (PackedScene) var Track
export (PackedScene) var Obstacle
onready var screen_size = get_viewport_rect().size

var last_position = 0

func _ready():
	randomize()
	$Player.position = $StartPosition.position
	add_track()

func add_track():
	var track = Track.instance()
	track.position = Vector2(last_position, 0)	
	
	track.connect("screen_entered", self, "add_track")
	$Tracks.add_child(track)
	
	var n_obstacles = round(rand_range(2, 5))
	for unused in range(n_obstacles):
		var obstacle = Obstacle.instance()
		obstacle.position = Vector2(rand_range(last_position + 256, last_position + screen_size.x), 
				round(rand_range(148 + 64, 490 - 64))) #64 obstacle diagonal
		$Obstacles.add_child(obstacle)
		
	last_position += screen_size.x

func _on_Timer_timeout():
	$Player.can_move = true
