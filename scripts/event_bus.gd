# eventbus
extends Node

# 공통
signal money_changed(new_amount: float)
signal gems_changed(new_amount: int)

# 광산(클리커)
signal mining_upgrade_purchased(upgrade_name: String, new_level: int)
signal pickaxe_power_upgraded(new_power: float)
signal ore_mined(amount: float)

signal generator_purchased(generator_id: String, new_count: int)
signal ore_generated(generator_id: String, amount: float)
signal passive_income_changed(new_income: float)

# 모험
signal adventure_upgrade_purchased(upgrade_name: String, new_level: int)
signal equipment_upgraded(equipment_type: String, new_level: int)
signal stage_started(stage_number: int)
signal stage_completed(stage_number: int, rewards: Dictionary)
