class_name MineGenerator
extends RefCounted

const SHARED_TIMER_THRESHOLD: float = 0.1

var item_id: String = ""
var item_data: Dictionary = {}

var level: int = 0
var current_cost: float = 0.0

var base_yield: float = 0.0
var current_yield_multiplier: float = 1.0
var interval: float = 0.0

var _cached_yield_per_second: float = 0.0
var _yield_cache_dirty: bool = true

var timer: Timer = null
var is_auto_generator: bool = false

func _init(id: String) -> void:
	item_id = id
	_load_item_data()
	_setup_initial_values()
	_setup_timer_if_needed()

func _load_item_data() -> void:
	if MineDefs.click_upgrades.has(item_id):
		item_data = MineDefs.click_upgrades[item_id]
	elif MineDefs.generators.has(item_id):
		item_data = MineDefs.generators[item_id]
	else:
		push_error("Item ID not found: " + item_id)
		item_data = {}

func _setup_initial_values() -> void:
	if item_data.is_empty():
		return
		
	base_yield = item_data.get("yield")
	current_yield_multiplier = item_data.get("yield_multiplier")
	interval = item_data.get("interval")
	current_cost = item_data.get("base_cost")
	
	is_auto_generator = interval > 0.0

func _setup_timer_if_needed() -> void:
	if is_auto_generator and interval > SHARED_TIMER_THRESHOLD:
		_create_individual_timer()

func _create_individual_timer() -> void:
	timer = Timer.new()
	timer.wait_time = interval
	timer.autostart = false
	timer.timeout.connect(_on_timer_tick)

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

func get_yield_per_second() -> float:
	if _yield_cache_dirty:
		_update_yield_cache()
	return _cached_yield_per_second

func _update_yield_cache() -> void:
	if not is_auto_generator or interval <= 0.0 or level == 0:
		_cached_yield_per_second = 0.0
	else:
		_cached_yield_per_second = (base_yield * level * current_yield_multiplier) / interval
		_yield_cache_dirty = false

func apply_purchase(quantity: int) -> void:
	if quantity < 1:
		return
		
	level += quantity
	
	_update_cost()
	_yield_cache_dirty = true
	start_generator()

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

func start_generator() -> void:
	if is_auto_generator and level > 0 and timer and timer.is_stopped():
		timer.start()

func stop_generator() -> void:
	if timer and not timer.is_stopped():
		timer.stop()

func trigger_click() -> float:
	if is_auto_generator or level == 0:
		return 0.0
	return base_yield * level * current_yield_multiplier
	
func _on_timer_tick() -> void:
	if level == 0:
		return
	
	var generated_amount: float = base_yield * level * current_yield_multiplier
	EventBus.mine_resource_generated.emit(generated_amount)

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
	
	if is_auto_generator and level > 0 and timer:
		timer.start()
