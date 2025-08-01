# 광산
extends Node

# 클릭 관련 값
var pickaxe_power: float = 1.0
var click_multiplier: float = 1.0

# 클릭 업그레이드
var click_upgrades = {
	"click_base": 0,
	"click_multiplier": 0
}

# 발전기 업그레이드
var generator_upgrades = {
	"g1": 0,
	"g2": 0,
	"g3": 0,
	"g4": 0
}

# 발전기 타이머
var generator_timers = {}

func _ready():
	_setup_generator_timers()

func _setup_generator_timers():
	for generator_id in MineData.get_all_generator_ids():
		var timer = Timer.new()
		timer.wait_time = 1.0
		timer.autostart = false
		timer.timeout.connect(_on_generator_tick.bind(generator_id))
		add_child(timer)
		generator_timers[generator_id] = timer

# 클릭 업그레이드 함수
func purchase_click_upgrade(upgrade_name: String) -> bool:
	var cost = get_click_upgrade_cost(upgrade_name)
	
	if GameData.spend_money(cost):
		click_upgrades[upgrade_name] += 1
		_apply_click_upgrade_effect(upgrade_name)
		EventBus.click_upgrade_purchased.emit(upgrade_name, click_upgrades[upgrade_name])
		return true
	return false

func get_click_upgrade_cost(upgrade_name: String) -> float:
	var data = MineData.get_upgrade_info(upgrade_name)
	var level = click_upgrades[upgrade_name]
	return data.base_cost * pow(data.cost_multiplier, level)

func _apply_click_upgrade_effect(upgrade_name: String):
	match upgrade_name:
		"click_base":
			var increase = MineData.get_upgrade_info(upgrade_name).power_increase
			pickaxe_power += increase
			EventBus.click_power_upgraded.emit(pickaxe_power)
		"click_multiplier":
			var multiplier = MineData.get_upgrade_info(upgrade_name).click_multiplier
			click_multiplier += multiplier

# 발전기 업그레이드 함수
func purchase_generator(generator_id: String) -> bool:
	var cost = get_generator_cost(generator_id)
	
	if GameData.spend_money(cost):
		generator_upgrades[generator_id] += 1
		_update_generator_timer(generator_id)
		EventBus.generator_purchased.emit(generator_id, generator_upgrades[generator_id])
		_update_total_passive_income()
		return true
	return false

func get_generator_cost(generator_id: String) -> float:
	var data = MineData.get_generator_info(generator_id)
	var count = generator_upgrades[generator_id]
	return data.base_cost * pow(data.cost_multiplier, count)

func get_generator_count(generator_id: String) -> int:
	return generator_upgrades[generator_id]

func get_generator_income_per_second(generator_id: String) -> float:
	var data = MineData.get_generator_info(generator_id)
	var count = generator_upgrades[generator_id]
	
	if count == 0:
		return 0.0
	
	return count * data.generation_speed * data.resource_per_generation

func get_total_passive_income() -> float:
	var total = 0.0
	for generator_id in generator_upgrades.keys():
		total += get_generator_income_per_second(generator_id)
	return total

func _update_generator_timer(generator_id: String):
	var timer = generator_timers[generator_id]
	var count = generator_upgrades[generator_id]
	var data = MineData.get_generator_info(generator_id)
	
	if count > 0:
		timer.wait_time = 1.0 / data.generation_speed
		if not timer.is_stopped():
			timer.stop()
		timer.start()
	else:
		timer.stop()

func _update_total_passive_income():
	GameData.passive_income = get_total_passive_income()
	EventBus.passive_income_changed.emit(GameData.passive_income)

func _on_generator_tick(generator_id: String):
	var count = generator_upgrades[generator_id]
	if count > 0:
		var data = MineData.get_generator_info(generator_id)
		var generated_amount = count * data.resource_per_generation
		
		GameData.add_money(generated_amount)
		EventBus.ore_generated.emit(generator_id, generated_amount)

# 클릭 처리
func process_mine_click() -> float:
	var base_amount = pickaxe_power
	var final_amount = base_amount * click_multiplier * GameData.boost_multiplier
	
	GameData.add_money(final_amount)
	EventBus.ore_mined.emit(final_amount)
	
	return final_amount
