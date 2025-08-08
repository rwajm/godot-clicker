class_name MineGenerator
extends RefCounted

var item_id: String
var item_data: Dictionary

var level: int = 0
var current_cost: float = 0.0

var base_yield: float = 0.0
var current_yield_multiplier: float = 1.0
var interval: float = 0.0

var timer: Timer = null
var is_auto_generator: bool = false

func _init(id: String):
	item_id = id
	_load_item_data()
	_setup_initial_values()
	
	if interval > 0.0:
		is_auto_generator = true
		# 0.1초 초과 간격만 개별 타이머 사용
		if interval > 0.1:
			_setup_timer()

func _load_item_data():
	if MineDefs.click_upgrades.has(item_id):
		item_data = MineDefs.click_upgrades[item_id]
	elif MineDefs.generators.has(item_id):
		item_data = MineDefs.generators[item_id]
	else:
		push_error("Item ID not found: " + item_id)
		item_data = {}

func _setup_initial_values():
	if item_data.is_empty():
		return
		
	base_yield = item_data.get("yield", 0.0)
	current_yield_multiplier = item_data.get("yield_multiplier", 1.0)
	interval = item_data.get("interval", 0.0)
	current_cost = item_data.get("base_cost", 0.0)

func _setup_timer():
	timer = Timer.new()
	timer.wait_time = interval
	timer.autostart = false
	timer.timeout.connect(_on_timer_tick)

func get_name() -> String:
	return item_data.get("name", "Unknown")

func get_description() -> String:
	return item_data.get("description", "No description")

func get_cost() -> float:
	return current_cost

func get_level() -> int:
	return level

func get_x1_yield() -> float:
	return base_yield * current_yield_multiplier

func get_current_yield() -> float:
	return base_yield * level * current_yield_multiplier

func get_yield_per_second() -> float:
	if is_auto_generator and interval > 0.0:
		return get_current_yield() / interval
	else:
		return 0.0

func can_purchase(available_money: float) -> bool:
	return available_money >= current_cost

func purchase() -> bool:
	level += 1
	if is_auto_generator:
		_start_generator_if_needed()
	_update_cost()
	return true

func _update_cost():
	var cost_multiplier = item_data.get("cost_multiplier", 1.15)
	var base_cost = item_data.get("base_cost", 0.0)
	
	current_cost = base_cost * pow(cost_multiplier, level)

func _start_generator_if_needed():
	if is_auto_generator and level > 0:
		if timer and timer.is_stopped():
			timer.start()

func _on_timer_tick():
	if level > 0:
		var generated_amount = base_yield * level * current_yield_multiplier
		EventBus.mine_resource_generated.emit(generated_amount)

func trigger_click() -> float:
	if not is_auto_generator and level > 0:
		var generated_amount = base_yield * level * current_yield_multiplier
		return generated_amount
	return 0.0

func stop_generator():
	if timer and not timer.is_stopped():
		timer.stop()

func start_generator():
	if timer and is_auto_generator and level > 0:
		timer.start()


func get_generator_info() -> Dictionary:
	return {
		"id": item_id,
		"name": get_name(),
		"description": get_description(),
		"level": get_level(),
		"cost": get_cost(),
		"current_yield": get_current_yield(),
		"yield_per_second": get_yield_per_second(),
		"interval": interval,
		"is_auto": is_auto_generator,
		"uses_shared_timer": is_auto_generator and interval <= 1.0
	}

func get_save_data() -> Dictionary:
	return {
		"item_id": item_id,
		"level": level,
		"current_yield_multiplier": current_yield_multiplier,
	}

func load_save_data(data: Dictionary):
	level = data.get("level", 0)
	current_yield_multiplier = data.get("current_yield_multiplier", 1.0)
	
	_update_cost()
	
	if is_auto_generator and level > 0:
		_start_generator_if_needed()
