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
	level_label.text = "Lv. %d" % item.get_level() if item.get_level() > 0 else ""
	
	if item.get_level() > 0:
		var current_yield = item.get_current_yield() if item is MineClick else item.get_yield_per_second()
		var suffix = " /Click" if item is MineClick else " /sec"
		generate_label.text = "+ %s %s" % [Utils.format_number(current_yield), suffix]
	else:
		generate_label.text = ""
	
	var cost = item.calculate_total_cost(purchase_quantity)
	
	cost_label.text = Utils.format_number(ceil(cost))
	quantity_label.text = "×%d" % purchase_quantity
	
	var yield_increase = item.get_x1_yield() * purchase_quantity
	var suffix = " /Click" if item is MineClick else ""
	generate_increase_label.text = "+ %s%s" % [Utils.format_number(yield_increase), suffix]

	upgrade_button.disabled = !GameData.can_afford(cost)

func _on_purchase_pressed():
	if item_id.is_empty():
		return
	
	var item = MineManager.get_item(item_id)
	if not item:
		return
	
	var total_cost = item.calculate_total_cost(purchase_quantity)
	
	if GameData.can_afford(total_cost):
		if MineManager.purchase_item(item_id, purchase_quantity):
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
