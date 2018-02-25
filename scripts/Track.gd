extends TileMap

signal screen_entered

func _on_Visibility_screen_exited():
	if not $VisibilityStart.visible:
		queue_free()

func _on_Visibility_screen_entered():
	emit_signal('screen_entered')