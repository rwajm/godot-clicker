class_name MineDefs
extends RefCounted

# 발전기 목록
static var generators = {
	"click": {
		"name": "click",
		"description": "click upgrade",
		"base_cost": 10.0,
		"cost_multiplier": 1.15,
		"yield": 1.0,
		"yield_multiplier": 1.0,
		"interval": 0.0
	},
	"test": {
		"name": "test",
		"description": "test generator",
		"base_cost": 1.0,
		"cost_multiplier": 1.0,
		"yield": 10000000.0,
		"yield_multiplier": 1.0,
		"interval": 0.07
	},
	"g1": {
		"name": "g1",
		"description": "generator 1",
		"base_cost": 100.0,
		"cost_multiplier": 1.1,
		"yield": 1.0,
		"yield_multiplier": 1.0,
		"interval": 10.0
	},
	"g2": {
		"name": "g2",
		"description": "generator 2",
		"base_cost": 10000.0,
		"cost_multiplier": 1.15,
		"yield": 100.0,
		"yield_multiplier": 1.0,
		"interval": 5.0
	},
	"g3": {
		"name": "g3",
		"description": "generator 3",
		"base_cost": 5000000.0,
		"cost_multiplier": 1.15,
		"yield": 300000.0,
		"yield_multiplier": 1.0,
		"interval": 60.0
	},
}

# 발전기 업그레이드 목록
static var upgrades = {
	"click_m": {
		"name": "click_m",
		"description": "x2 click yield multiplier",
		"target_generator": "click",
		"upgrade_type": "yield_multiplier",
		"base_cost": 1000.0,
		"cost_multiplier": 150,
		"multiply_value": 5.0,
		"max_level": 50,
	},
	"g1_m": {
		"name": "g1_m",
		"description": "x20 g1 yield multiplier",
		"target_generator": "g1",
		"upgrade_type": "yield_multiplier",
		"base_cost": 1000.0,
		"cost_multiplier": 1500,
		"multiply_value": 5.0,
		"max_level": 6,
	},
	"g1_i": {
		"name": "g1_i",
		"description": "x2 g1 speed",
		"target_generator": "g1",
		"upgrade_type": "interval",
		"base_cost": 200.0,
		"cost_multiplier": 150,
		"multiply_value": 2.0,
		"max_level": 10
	},
	"g2_m": {
		"name": "g2_m",
		"description": "x3 g2 yield multiplier",
		"target_generator": "g2",
		"upgrade_type": "yield_multiplier",
		"base_cost": 80000.0,
		"cost_multiplier": 200,
		"multiply_value": 3.0,
		"max_level": 15
	},
	"g2_i": {
		"name": "g2_i",
		"description": "x1.5 g2 speed",
		"target_generator": "g2",
		"upgrade_type": "interval",
		"base_cost": 1500.0,
		"cost_multiplier": 100,
		"multiply_value": 1.5,
		"max_level": 12,
	},
	"g3_m": {
		"name": "g3_m",
		"description": "x12 g3 yield multiplier",
		"target_generator": "g3",
		"upgrade_type": "yield_multiplier",
		"base_cost": 5000.0,
		"cost_multiplier": 400,
		"multiply_value": 12.0,
		"max_level": 5
	},
	"g3_i": {
		"name": "g3_i",
		"description": "x1.25 g3 speed",
		"target_generator": "g3",
		"upgrade_type": "interval",
		"base_cost": 80000.0,
		"cost_multiplier": 1000,
		"multiply_value": 1.25,
		"max_level": 30,
	}
}
