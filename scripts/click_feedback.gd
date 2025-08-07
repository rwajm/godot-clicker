extends MarginContainer

@onready var label = $Label

func show_click_feedback(amount: float, start_position: Vector2):
	var offset = Vector2(-self.size.x/2, -self.size.y/2)
	var randX = Vector2(randf_range(-20, 20), 0)
	position = start_position + offset + randX
	label.position = Vector2.ZERO
	
	label.text = "+ " + Utils.format_number(amount)
	label.visible = true
	label.modulate = Color.WHITE
	
	# 애니메이션
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(label, "position", label.position + Vector2(0, -150), 1.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	tween.tween_callback(queue_free).set_delay(1.0)
