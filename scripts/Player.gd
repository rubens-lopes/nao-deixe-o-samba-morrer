extends KinematicBody2D

signal hit
signal musicians_count_changed

export (PackedScene) var Musician

export var acceleration = Vector2(350, 1500)
export var friction = Vector2(-10, -150)
export var bounce_coefficent = 0.2
export var max_velocity = Vector3(500, 700, 1500)

var velocity = Vector2()
var can_move = false
var state = IDLE
var musicians = 0

enum {THRUST, AUTO_BREAK, BREAK, IDLE}

func _physics_process(delta):
	if not can_move:
		return
	
	var acc = Vector2()
	if Input.is_action_pressed("ui_up"):
		acc.y = -1
	if Input.is_action_pressed("ui_down"):
		acc.y = 1
		
	acc.y *= acceleration.y
	if acc.y == 0:
        acc.y = velocity.y * friction.y * delta
	
	acc.x = 1
	if Input.is_action_pressed("ui_left"):
		state = BREAK
		acc.x = -1
	elif Input.is_action_pressed("ui_right"):
		state = THRUST
	elif velocity.x > 750:
		state = AUTO_BREAK
	else:
		state = IDLE
		
	acc.x *= acceleration.x
	if state == AUTO_BREAK:
		acc.x = velocity.x * friction.x * delta
	
	velocity += acc * delta
	match state:
		AUTO_BREAK: velocity.x = max(velocity.x, max_velocity.y)
		THRUST: velocity.x = min(velocity.x, max_velocity.z)
		BREAK: velocity.x = max(velocity.x, max_velocity.x)
		IDLE: velocity.x = min(velocity.x, max_velocity.y)
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		emit_signal('hit', collision.remainder / delta)
		velocity = velocity.bounce(collision.normal) * bounce_coefficent
		if not $Crash.playing:
			$Crash.play()

func _on_Main_new_game():
	$Timer.start()
	velocity = Vector2()
	
	var instruments = [
		preload("res://audio/agogo.ogg"),
		preload("res://audio/baixo.ogg"),
		preload("res://audio/caixa.ogg"),
		preload("res://audio/cavaco.ogg"),
		preload("res://audio/chocalho.ogg"),
		preload("res://audio/pandeiro.ogg"),
		preload("res://audio/surdo.ogg"),
		preload("res://audio/melodia.ogg"),
		preload("res://audio/tamborim.ogg"),
#		preload("res://audio/vozes.ogg")
	]

	musicians = len(instruments)
	var positions = []
	while instruments:
		var pos = randi() % 10
		if pos in positions:
			continue

		positions.append(pos)
		var start = get_node('MusicianStart%s' % pos)

		var musician = Musician.instance()
		var instrument = instruments.pop_back()
		musician.get_node('Instrument').stream = instrument
		musician.position = start.position
		musician.rotation = rand_range(0, 2 * PI)
		connect('hit', musician, '_on_Player_hit')
		get_parent().connect('game_over', musician, '_on_Main_game_over')
		get_node('Timer').connect('timeout', musician, '_on_PlayerTimer_timeout')
		add_child(musician) 

func _on_Timer_timeout():
	can_move = true

func _on_Deck_body_exited(body):
	if not is_connected('hit', body, '_on_Player_hit'):
		return
	
	disconnect('hit', body, '_on_Player_hit')
	musicians -= 1
	emit_signal('musicians_count_changed', musicians)
	
	var pos = body.global_position
	pos.y -= 80
	call_deferred('remove_child', body)
	get_parent().call_deferred('add_child', body)
	
	body.fall(pos)

func _on_Main_game_over():
	can_move = false