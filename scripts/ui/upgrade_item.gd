class_name UpgradeItem
extends PanelContainer

# 업그래이드 정보
var item_id: String = ""
var purchase_quantity: int = 1

# UI 노드 참조 
@onready var name_label = $HBoxContainer/VBoxContainer/HBoxContainer/NameLabel
@onready var level_label = $HBoxContainer/VBoxContainer/HBoxContainer/LevelLabel
@onready var generate_label = $HBoxContainer/VBoxContainer/GenerateLabel
@onready var upgrade_button = $HBoxContainer/UpgradeButton
@onready var quantity_label = $HBoxContainer/UpgradeButton/PanelContainer/Control/QuantityLabel
@onready var cost_label = $HBoxContainer/UpgradeButton/PanelContainer/Control/VBoxContainer/CostLabel
@onready var generate_increase_label = $HBoxContainer/UpgradeButton/PanelContainer/Control/VBoxContainer/GenerationLabel

func _ready():
	upgrade_button.pressed.connect(_on_purchase_pressed)
	
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.mine_upgrade_purchased.connect(_on_mine_upgrade_purchased)
	EventBus.mine_generator_purchased.connect(_on_mine_generator_purchased)

# 업그레이드 아이템 초기화
func setup_upgrade(id: String):
	item_id = id
	_update_display()

func set_purchase_quantity(quantity: int):
	purchase_quantity = quantity
	quantity_label.text = "×%d" % purchase_quantity
	_update_display()

func _update_display():
	if item_id.is_empty():
		return
	
	var item = MineManager.get_item(item_id)
	if not item:
		return
	
	# 발전기 정보
	name_label.text = item.get_name()
	
	var level = item.get_level()
	var current_yield = item.get_current_yield()
	
	if level:
		level_label.text = "Lv. %d" % level
	else:
		level_label.text = ""
	
	if current_yield:
		if item.is_auto_generator:
			generate_label.text = "+ %d /sec" % current_yield
		else:
			generate_label.text = "+ %d /click" % current_yield
	else:
			generate_label.text = ""
	
	# 발전기 구매 정보
	var single_cost = item.get_cost()
	var total_cost = _calculate_total_cost(single_cost, purchase_quantity, item.item_data.cost_multiplier)
	var yield_increase = item.get_x1_yield() * purchase_quantity
	
	cost_label.text = _format_number(total_cost)
	quantity_label.text = "×%d" % purchase_quantity
	
	if item.is_auto_generator:
		generate_increase_label.text = "+ %d /sec" % yield_increase
	else:
		generate_increase_label.text = "+ %d /click" % yield_increase
	
	# 발전기 구매 가능 여부
	upgrade_button.disabled = !GameData.can_afford(total_cost)

func _calculate_total_cost(base_cost: float, quantity: int, multiplier: float) -> float:
	var total = 0.0
	var current_cost = base_cost
	
	for i in range(quantity):
		total += current_cost
		current_cost *= multiplier
	
	return total

func _format_number(number: float) -> String:
	if number < 1000:
		return str(int(number))
	elif number < 1000000:
		return "%.1fK" % (number / 1000.0)
	elif number < 1000000000:
		return "%.1fM" % (number / 1000000.0)
	else:
		return "%.1fB" % (number / 1000000000.0)

func _on_purchase_pressed():
	if item_id.is_empty():
		return
	
	var item = MineManager.get_item(item_id)
	if not item:
		return
	
	var single_cost = item.get_cost()
	var total_cost = _calculate_total_cost(single_cost, purchase_quantity, item.item_data.cost_multiplier)
	
	if GameData.can_afford(total_cost):
		# �곗냽�쇰줈 援щℓ
		var successful_purchases = 0
		for i in range(purchase_quantity):
			if MineManager.purchase_item(item_id):
				successful_purchases += 1
			else:
				break
		
		if successful_purchases > 0:
			_show_purchase_effect()
			_update_display()

func _show_purchase_effect():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _on_money_changed(new_amount: float):
	_update_display()

func _on_mine_upgrade_purchased(upgrade_id: String, new_level: int):
	if upgrade_id == item_id:
		_update_display()

func _on_mine_generator_purchased(generator_id: String, new_count: int):
	if generator_id == item_id:
		_update_display()
