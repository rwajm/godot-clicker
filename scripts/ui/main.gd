extends Control

@onready var score_label = $ClickerControl/ScoreLabel
@onready var income_label = $ClickerControl/ScoreLabel #추가예정 
@onready var quantity_selector = $CanvasLayer/UpgradePanel/UpgradeVbox/UpgradePanelContainer/VBoxContainer/QuantitySelectorButton
@onready var upgrade_container = $CanvasLayer/UpgradePanel/UpgradeVbox/UpgradePanelContainer/VBoxContainer/ScrollContainer/VBoxContainer

var click_feedback_scene = preload("res://scenes/click_feedback.tscn")

var purchase_quantity = 1
var purchase_quantities = [1, 10, 100]
var current_quantity_index = 0

func _ready():
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.mine_clicked.connect(_on_mine_clicked)
	quantity_selector.pressed.connect(_on_quantity_selector_pressed)
	
	_setup_upgrade_items()
	_update_score_display()

func _setup_upgrade_items():
	for child in upgrade_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	var upgrade_item_scene = preload("res://scenes/upgrade_item.tscn")
	
	# 클릭 
	if not MineDefs.click_upgrades.is_empty():
		_add_category_header("Click Upgrades")
		
		var click_ids = MineDefs.click_upgrades.keys()
		#click_ids.sort() #정렬(추후)
		
		for upgrade_id in click_ids:
			var upgrade_item = upgrade_item_scene.instantiate()
			upgrade_container.add_child(upgrade_item)
			upgrade_item.setup_upgrade(upgrade_id)
			upgrade_item.set_purchase_quantity(purchase_quantity)
	
	# 발전기
	if not MineDefs.generators.is_empty():
		_add_category_header("Generators")
		
		var generator_ids = MineDefs.generators.keys()
		#generator_ids.sort() #정렬(추후)
		
		for generator_id in generator_ids:
			var upgrade_item = upgrade_item_scene.instantiate()
			upgrade_container.add_child(upgrade_item)
			upgrade_item.setup_upgrade(generator_id)
			upgrade_item.set_purchase_quantity(purchase_quantity)

func _add_category_header(title: String):
	var header = Label.new()
	header.text = title
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 28)
	header.add_theme_color_override("font_color", Color.WHITE)
	header.custom_minimum_size.y = 48
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	header.add_theme_stylebox_override("normal", style_box)
	
	upgrade_container.add_child(header)

func _on_mine_clicked(amount: float):
	_show_click_feedback(amount)
	
func _on_money_changed(new_amount: float):
	_update_score_display()

func _update_score_display():
	if score_label:
		score_label.text = Utils.format_number(GameData.money)

# 초당 수입(클릭 반영)
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

# 클릭 효과(클릭당 수입 표시) 
func _show_click_feedback(amount: float):
	var mouse_position = get_global_mouse_position()
	
	var feedback_effect = click_feedback_scene.instantiate()
	add_child(feedback_effect)
	feedback_effect.show_click_feedback(amount, mouse_position)

func _on_quantity_selector_pressed():
	current_quantity_index = (current_quantity_index + 1) % purchase_quantities.size()
	purchase_quantity = purchase_quantities[current_quantity_index]
	quantity_selector.text = "×%d" % purchase_quantity
	
	_update_all_upgrade_quantities()

func _update_all_upgrade_quantities():
	for child in upgrade_container.get_children():
		if child.has_method("set_purchase_quantity"):
			child.set_purchase_quantity(purchase_quantity)
