# scripts/managers/mine_manager.gd (AutoLoad)
extends Node

var mine_items: Dictionary = {}

var base_click_power: float = 1.0
var click_multiplier: float = 1.0

var boost_multiplier: float = 1.0
var boost_isActive: bool = false

var income_timer: Timer

func _ready():
	_initialize_mine_items()
	_connect_signals()

func _initialize_mine_items():
	for upgrade_id in MineDefs.click_upgrades.keys():
		var generator = MineGenerator.new(upgrade_id)
		mine_items[upgrade_id] = generator
		if generator.timer:
			add_child(generator.timer)
	
	for generator_id in MineDefs.generators.keys():
		var generator = MineGenerator.new(generator_id)
		mine_items[generator_id] = generator
		if generator.timer:
			add_child(generator.timer)

func _connect_signals():
	EventBus.mine_resource_generated.connect(_on_resource_generated)

func _on_resource_generated(item_id: String, amount: float):
	var final_amount = amount * boost_multiplier
	GameData.add_money(final_amount)

func purchase_item(item_id: String) -> bool:
	if not mine_items.has(item_id):
		return false
	
	var item = mine_items[item_id]
	var cost = item.get_cost()
	
	if GameData.spend_money(cost):
		item.purchase()
		
		if item.is_auto_generator:
			EventBus.mine_generator_purchased.emit(item_id, item.count)
		else:
			EventBus.mine_upgrade_purchased.emit(item_id, item.level)
		
		_update_income()
		return true
	
	return false

func get_item_cost(item_id: String) -> float:
	if mine_items.has(item_id):
		return mine_items[item_id].get_cost()
	return 0.0

func get_item_level(item_id: String) -> int:
	if mine_items.has(item_id):
		return mine_items[item_id].get_level()
	return 0

func get_item_yield_per_second(item_id: String) -> float:
	if mine_items.has(item_id):
		return mine_items[item_id].get_yield_per_second()
	return 0.0

func get_income() -> float:
	var total = 0.0
	for generator_id in MineDefs.generators.keys():
		if mine_items.has(generator_id):
			total += mine_items[generator_id].get_yield_per_second()
	return total

func _update_income():
	EventBus.mine_income_changed.emit(get_income())

func process_mine_click() -> float:
	var total_generated = base_click_power
	for upgrade_id in MineDefs.click_upgrades.keys():
		if mine_items.has(upgrade_id):
			var click_yield = mine_items[upgrade_id].trigger_click()
			total_generated += click_yield
	
	var final_amount = total_generated * click_multiplier * boost_multiplier

	print("final_amount =", final_amount)
	GameData.add_money(final_amount)
	EventBus.mine_clicked.emit(final_amount)
	
	return final_amount

func get_item(item_id: String) -> MineGenerator:
	return mine_items.get(item_id, null)

func get_all_click_upgrades() -> Array:
	var upgrades = []
	for upgrade_id in MineDefs.click_upgrades.keys():
		if mine_items.has(upgrade_id):
			upgrades.append(mine_items[upgrade_id])
	return upgrades

func get_all_generators() -> Array:
	var generators = []
	for generator_id in MineDefs.generators.keys():
		if mine_items.has(generator_id):
			generators.append(mine_items[generator_id])
	return generators

# 발전기 제어
func stop_all_generators():
	for generator_id in MineDefs.generators.keys():
		if mine_items.has(generator_id):
			mine_items[generator_id].stop_generator()
	if income_timer:
		income_timer.stop()

func start_all_generators():
	for generator_id in MineDefs.generators.keys():
		if mine_items.has(generator_id):
			mine_items[generator_id].start_generator()
	if income_timer:
		income_timer.start()

# save & load
func get_save_data() -> Dictionary:
	var save_data = {}
	
	for item_id in mine_items.keys():
		save_data[item_id] = mine_items[item_id].get_save_data()
	
	return {
		"base_click_power": base_click_power,
		"mine_items": save_data
	}

func load_save_data(data: Dictionary):	
	var items_data = data.get("mine_items", {})
	for item_id in items_data.keys():
		if mine_items.has(item_id):
			mine_items[item_id].load_save_data(items_data[item_id])
	
	_update_income()
	
# debugging
func debug_print_all_items():
	print("=== Mine Items Status ===")
	for item_id in mine_items.keys():
		var item = mine_items[item_id]
		print("%s: Level/Count=%d, Cost=%.2f, Yield/sec=%.2f" % [
			item_id, 
			item.get_level(), 
			item.get_cost(), 
			item.get_yield_per_second()
		])

func debug_add_money(amount: float):
	GameData.add_money(amount)
	print("Added %s money. Total: %s" % [amount, GameData.money])

func debug_reset_all():
	for item_id in mine_items.keys():
		var item = mine_items[item_id]
		item.level = 0
		item.count = 0
		item._update_cost()
		if item.timer and not item.timer.is_stopped():
			item.timer.stop()
	
	GameData.money = 0.0
	_update_income()
	print("All items reset!")
