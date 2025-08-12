extends Node

# goods status
var money: float = 0.0 : set = set_money
var gems: int = 0 : set = set_gems

func set_money(value: float):
	money = value
	EventBus.money_changed.emit(money)

func set_gems(value: int):
	gems = value
	EventBus.gems_changed.emit(gems)

func add_money(amount: float):
	self.money += amount
	EventBus.money_changed.emit(money)

func can_afford(cost: float) -> bool:
	return money >= cost

func spend_money(cost: float) -> bool:
	if can_afford(cost):
		self.money -= cost
		EventBus.money_changed.emit(money)
		return true
	return false
