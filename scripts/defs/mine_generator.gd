class_name MineGenerator
extends MineItem

const SHARED_TIMER_THRESHOLD: float = 0.1

var interval: float = 0.0

var _cached_yield_per_second: float = 0.0
var _yield_cache_dirty: bool = true

var timer: Timer = null

func _init(id: String) -> void:
	super(id)
	_setup_generator_values()
	_setup_timer_if_needed()

func _setup_generator_values() -> void:
	if item_data.is_empty():
		return
	interval = item_data.get("interval")

func _setup_timer_if_needed() -> void:
	if interval > SHARED_TIMER_THRESHOLD:
		_create_individual_timer()

func _create_individual_timer() -> void:
	timer = Timer.new()
	timer.wait_time = interval
	timer.autostart = false
	timer.timeout.connect(_on_timer_tick)

func get_yield_per_second() -> float:
	if _yield_cache_dirty:
		_update_yield_cache()
	return _cached_yield_per_second

func _update_yield_cache() -> void:
	if interval <= 0.0 or level == 0:
		_cached_yield_per_second = 0.0
	else:
		_cached_yield_per_second = (base_yield * level * current_yield_multiplier) / interval
	_yield_cache_dirty = false

func apply_purchase(quantity: int) -> void:
	super.apply_purchase(quantity)
	_yield_cache_dirty = true
	start_generator()

func start_generator() -> void:
	if level > 0 and timer and timer.is_stopped():
		timer.start()

func stop_generator() -> void:
	if timer and not timer.is_stopped():
		timer.stop()

func _on_timer_tick() -> void:
	if level == 0:
		return
	
	var generated_amount: float = base_yield * level * current_yield_multiplier
	EventBus.mine_resource_generated.emit(generated_amount)

func load_save_data(data: Dictionary) -> void:
	super.load_save_data(data)
	_yield_cache_dirty = true
	
	if level > 0 and timer:
		timer.start()
