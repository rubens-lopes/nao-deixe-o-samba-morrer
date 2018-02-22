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
	var obs = []
	for unused in range(n_obstacles):
		var obstacle = Obstacle.instance()
		var t_pos = track.world_to_map(
				Vector2(rand_range(last_position + 512, last_position + screen_size.x), 
				rand_range(128, 512)))
		
		var pos = t_pos * 128
		pos.y += 64
#		pos.y = max(pos.y, 128 + 23 + 20)
		
		if not obs.has(pos):
			obs.append(pos)
			obstacle.position = pos
			$Obstacles.add_child(obstacle)
		else:
			obstacle.queue_free()
		
	last_position += screen_size.x
	print('end of track %s' % track.name)

func _on_Timer_timeout():
	$Player.can_move = true
	pass
