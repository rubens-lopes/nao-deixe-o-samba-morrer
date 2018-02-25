extends Node2D

signal game_over
signal new_game

export (PackedScene) var Track
export (PackedScene) var Obstacle

onready var screen_size = get_viewport_rect().size

var last_position
var score
var high_score = 0
var high_dist = 0
var game_running

func _ready():
	randomize()
	$Player.connect('musicians_count_changed', self, 'game_over')
	new_game()
	
func new_game():
	print('new_game')
	last_position = 0
	score = 0
	game_running = true
	
	emit_signal('new_game')
	$Player.position = $StartPosition.position
	add_track()
	$ScoreTimer.start()
	
func add_track():
	var track = Track.instance()
	track.position = Vector2(last_position, 0)
	
	track.connect('screen_entered', self, 'add_track')
	$Tracks.add_child(track)
	
	var n_obstacles = round(rand_range(2, 5))
	var obs = []
	while len(obs) < n_obstacles:
		var t_pos = track.world_to_map(
				Vector2(rand_range(last_position + (512 if last_position == 0 else 0), 
						last_position + screen_size.x), 
				rand_range(128, 512)))
		
		var pos = t_pos * 128
		pos.y += 64
		
		if pos in obs:
			continue
			
		obs.append(pos)
		var obstacle = Obstacle.instance()
		obstacle.position = pos
		$Obstacles.add_child(obstacle)
		
	last_position += screen_size.x
	
func game_over(musicians):
	if not game_running or musicians > 0:
		return
		
	emit_signal('game_over')
	game_running = false
	$GameOverTimer.start()
	$ScoreTimer.stop()
	
func _on_GameOverTimer_timeout():
	new_game()

func _on_ScoreTimer_timeout():
	score += 1
	
	if score > high_score:
		high_score = score
		
func _process(delta):
	var pos = $Player.position
	pos.y = $Score.rect_position.y
	$Score.rect_position = pos
	
	var dist = int(floor(($Player.position.x - 70) / 10))
	if dist > high_dist:
		high_dist = dist
		
	$Score.text = 'dist.: %s meters | %s || time: %s seconds | %s' % [dist, high_dist, score, high_score]