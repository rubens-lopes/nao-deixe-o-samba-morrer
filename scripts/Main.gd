extends Node2D

signal game_over

export (PackedScene) var Track
export (PackedScene) var Obstacle
export (PackedScene) var Musician

onready var screen_size = get_viewport_rect().size

var last_position
var musicians
var time

func _ready():
	randomize()
	$Player/Deck.connect("body_exited", self, "_on_Musician_exited")
	new_game()
func new_game():
	last_position = 0
	time = 0
	_game_over = false
	$Timer.start()
	$Player.position = $StartPosition.position
	$Player.velocity = Vector2(0, 0)
	add_track()
	
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
	
	musicians = len(instruments)
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
		$Player.connect("hit", musician, '_on_Player_hit') 
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

var _game_over = false 
func _process(delta):
	var pos = $Player.position
	pos.y = $Score.rect_position.y
	$Score.rect_position = pos
	
	var dist = int(floor(($Player.position.x - 70) / 10))
	$Score.text = 'dist.: %s meters | time: %s seconds | %s musicians' % [dist, time, musicians]
	
	if not _game_over and musicians < 1:
		_game_over = true
		game_over()
	pass
	
func game_over():
	$Player.can_move = false
	$GameOverTimer.start()
	$ScoreTimer.stop()
	
func _on_GameOverTimer_timeout():
	new_game()
	
func _on_Timer_timeout():
	$Player.can_move = true
	$ScoreTimer.start()
	pass

func _on_Musician_exited(body):
	if not $Player.is_connected('moved', body, '_on_Player_moved'):
		return
	
	$Player.disconnect('moved', body, '_on_Player_moved')
	$Player.disconnect('hit', body, '_on_Player_hit')
	body.velocity.x = 0
	body.collision_layer = 0
	body.collision_mask = 0
	musicians -= 1
	body.get_node('Instrument').stop()

func _on_ScoreTimer_timeout():
	time += 1
	pass # replace with function body
