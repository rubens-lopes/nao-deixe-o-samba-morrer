extends KinematicBody2D

export var friction = Vector2(0.4, 0.65)

var _friction
var velocity = Vector2(0, 0)

func _ready():
	_friction = rand_range(friction.x, friction.y)
#	print('%s: %s' % [name, _friction])

func _physics_process(delta):
	var acc = velocity * -friction
	velocity += acc
	
	move_and_slide(velocity)

func _on_Player_hit(reminder):
	velocity = reminder.rotated(rand_range(0, 2 * PI))

func _on_Main_game_over():
	$Timer.start()

func _on_Timer_timeout():
	queue_free()

func _on_PlayerTimer_timeout():
	$Instrument.play()

func fall(pos):
	print('fall')
	print($Instrument.stream.resource_name)
	$Instrument.stop()
	collision_layer = 0
	collision_mask = 0
	_friction = 0.0001
	position = pos
	velocity *= 25