extends Control

@onready var score_label = $ClickerControl/ScoreLabel
@onready var income_label = $ClickerControl/IncomeLabel

var update_timer : Timer
var click_feedback_scene = preload("res://scenes/click_feedback.tscn")

func _ready():
	update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_update_income_display)
	update_timer.autostart = true
	add_child(update_timer)
	
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.mine_clicked.connect(_on_mine_clicked)
	
	_update_score_display()

	
func _on_mine_clicked(amount: float):
	_show_click_feedback(amount)
	
func _on_money_changed(new_amount: float):
	_update_score_display()

func _update_score_display():
	if score_label:
		score_label.text = Utils.format_number(floor(GameData.money))

func _on_income_changed(new_income: float):
	_update_income_display()

func _update_income_display():
	if income_label:
		var income_per_sec = MineManager.get_income()
		if income_per_sec > 0:
			income_label.text = "%s/sec" % Utils.format_number(income_per_sec)
			income_label.visible = true
		else:
			income_label.visible = false

func _show_click_feedback(amount: float):
	var mouse_position = get_global_mouse_position()
	
	var feedback_effect = click_feedback_scene.instantiate()
	add_child(feedback_effect)
	feedback_effect.show_click_feedback(amount, mouse_position)
