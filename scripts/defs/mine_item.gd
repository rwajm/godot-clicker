class_name MineItem
extends RefCounted

var item_id: String = ""
var item_data: Dictionary = {}

var level: int = 0
var current_cost: float = 0.0

var base_yield: float = 0.0
var current_yield_multiplier: float = 1.0

func _init(id: String) -> void:
	item_id = id
	_load_item_data()
	_setup_initial_values()

func _load_item_data() -> void:
	if MineDefs.generators.has(item_id):
		item_data = MineDefs.generators[item_id]
	else:
		push_error("Item ID not found: " + item_id)
		item_data = {}

func _setup_initial_values() -> void:
	if item_data.is_empty():
		return
		
	base_yield = item_data.get("yield")
	current_yield_multiplier = item_data.get("yield_multiplier")
	current_cost = item_data.get("base_cost")

func get_name() -> String:
	return item_data.get("name", "Unknown Item")

func get_description() -> String:
	return item_data.get("description", "No description available")

func get_cost() -> float:
	return current_cost

func get_level() -> int:
	return level

func get_x1_yield() -> float:
	return base_yield * current_yield_multiplier

func get_current_yield() -> float:
	if level == 0:
		return 0.0
	return base_yield * level * current_yield_multiplier

func apply_purchase(quantity: int) -> void:
	if quantity < 1:
		return
		
	level += quantity
	_update_cost()

func calculate_total_cost(quantity: int) -> float:
	if quantity <= 0 or item_data.is_empty():
		return 0.0
	
	var base_cost: float = item_data.get("base_cost")
	var cost_multiplier: float = item_data.get("cost_multiplier")
	var current_level_cost = base_cost * pow(cost_multiplier, level)
	
	if cost_multiplier == 1.0:
		return current_level_cost * quantity
	
	# a * (r^n - 1) / (r - 1)
	return current_level_cost * (pow(cost_multiplier, quantity) - 1) / (cost_multiplier - 1)

func _update_cost() -> void:
	if item_data.is_empty():
		return
		
	var base_cost: float = item_data.get("base_cost")
	var cost_multiplier: float = item_data.get("cost_multiplier")
	current_cost = base_cost * pow(cost_multiplier, level)

func get_save_data() -> Dictionary:
	return {
		"item_id": item_id,
		"level": level,
		"current_yield_multiplier": current_yield_multiplier
	}

func load_save_data(data: Dictionary) -> void:
	level = data.get("level", 0)
	current_yield_multiplier = data.get("current_yield_multiplier", 1.0)
	_update_cost()
