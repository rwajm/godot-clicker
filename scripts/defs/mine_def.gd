# mine 업그레이드 정의
class_name MineDefs
extends RefCounted

# 클릭 업그레이드 목록 (interval == 0 => 클릭 트리거)
static var click_upgrades = {
	"click": {
		"name": "click",
		"description": "click upgrade",
		"base_cost": 10.0,
		"cost_multiplier": 1.15,
		"yield": 1.0,
		"yield_multiplier": 1.0,
		"interval": 0.0
	},
	"c1": {
		"name": "c1",
		"description": "click upgrade 1",
		"base_cost": 500.0,
		"cost_multiplier": 1.25,
		"yield": 5.0,
		"yield_multiplier": 1.2,
		"interval": 0.0
	},
	"c2": {
		"name": "c2",
		"description": "click upgrade 2",
		"base_cost": 2000.0,
		"cost_multiplier": 1.3,
		"yield": 2.0,
		"yield_multiplier": 1.5,
		"interval": 0.0
	}
}

# 발전기 목록
static var generators = {
	"g1": {
		"name": "g1",
		"description": "generator 1",
		"base_cost": 15.0,
		"cost_multiplier": 1.07,
		"yield": 1.0,
		"yield_multiplier": 1.0,
		"interval": 1.0
	},
	"g2": {
		"name": "g2",
		"description": "generator 2",
		"base_cost": 100.0,
		"cost_multiplier": 1.15,
		"yield": 4.0,
		"yield_multiplier": 1.0,
		"interval": 0.5
	},
	"g3": {
		"name": "g3",
		"description": "generator 3",
		"base_cost": 1100.0,
		"cost_multiplier": 1.14,
		"yield": 8.0,
		"yield_multiplier": 1.0,
		"interval": 0.25
	},
}
