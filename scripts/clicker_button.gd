extends Button

var original_scale = scale
	
func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	if MineManager:
		MineManager.process_mine_click()
	
	_play_click_animation()

func _play_click_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", original_scale * 1.1, 0.1)
	tween.tween_property(self, "scale", original_scale, 0.1).set_delay(0.1)
