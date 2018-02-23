extends Node2D

export (PackedScene) var Track
export (PackedScene) var Obstacle
export (PackedScene) var Musician

onready var screen_size = get_viewport_rect().size

var instruments = [
	preload("res://audio/agogo.ogg"),
	preload("res://audio/baixo.ogg"),
	preload("res://audio/caixa.ogg"),
	preload("res://audio/cavaco.ogg"),
	preload("res://audio/chocalho.ogg"),
	preload("res://audio/pandeiro.ogg"),
	preload("res://audio/surdo.ogg"),
	preload("res://audio/tamborim.ogg"),
	preload("res://audio/vozes.ogg")
	]
	
var last_position = 0

func _ready():
	randomize()
	$Player.position = $StartPosition.position
	$Player/Deck.connect("body_exited", self, "_on_Musician_exited")
	add_track()
	
	var positions = []
	while instruments:
		var pos = randi() % 9
		if pos in positions:
			continue
		
		positions.append(pos)
		pos = $Player.get_node("MusicianStart%s" % pos).global_position
		pos.y -= 80
		
		var musician = Musician.instance()
		var instrument = instruments.pop_back()
		musician.get_node("Instrument").stream = instrument
		musician.position = pos
		musician.rotation = rand_range(0, 2 * PI)
		$Player.connect("moved", musician, '_on_Player_moved') 
		$Musicians.add_child(musician)

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
				Vector2(rand_range(last_position + 512, 
						last_position + screen_size.x), 
				rand_range(128, 512)))
		
		var pos = t_pos * 128
		pos.y += 64
		
		if not obs.has(pos):
			obs.append(pos)
			obstacle.position = pos
			$Obstacles.add_child(obstacle)
		else:
			obstacle.queue_free()
		
	last_position += screen_size.x

func _on_Timer_timeout():
	$Player.can_move = true
	pass

func _on_Musician_exited(body):
	body.queue_free()