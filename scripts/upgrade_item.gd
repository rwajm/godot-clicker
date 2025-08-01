# scenes/ui/upgrade_item.gd
class_name UpgradeItem
extends Control

# 업그레이드 정보
var upgrade_category: String = ""  # "mining", "adventure" 등
var upgrade_name: String = ""      # "pickaxe", "sword" 등

# UI 노드 참조
@onready var name_label = $UpgradeInfo/NameLabel
@onready var description_label = $UpgradeInfo/DescriptionLabel
@onready var level_label = $UpgradeInfo/StatsContainer/LevelLabel
@onready var cost_label = $UpgradeInfo/StatsContainer/CostLabel
@onready var icon_texture = $IconTexture
@onready var purchase_button = $PurchaseButton

func _ready():
	purchase_button.pressed.connect(_on_purchase_pressed) # 업그레이드 버튼
	
	EventBus.money_changed.connect(_on_money_changed)
	
	# 카테고리별 업그레이드 구매 시그널 연결
	EventBus.mining_upgrade_purchased.connect(_on_mining_upgrade_purchased)
	EventBus.adventure_upgrade_purchased.connect(_on_adventure_upgrade_purchased)

# 업그레이드 아이템 초기화
func setup_upgrade(category: String, upgrade_key: String):
	upgrade_category = category
	upgrade_name = upgrade_key
	
	_load_upgrade_data()
	_update_display()

func _load_upgrade_data():
	var data = _get_upgrade_data()
	
	name_label.text = data.name
	description_label.text = data.description
	icon_texture.texture = load("res://icons/" + upgrade_category + "/" + upgrade_name + ".png")

func _get_upgrade_data() -> Dictionary:
	match upgrade_category:
		"mining":
			return MineData.upgrade_data[upgrade_name]
		#"adventure":
			#return AdventureData.upgrade_data[upgrade_name]
		_:
			return {}

func _update_display():
	var current_level = _get_current_level()
	var cost = _get_upgrade_cost()
	
	level_label.text = "Lv. " + str(current_level)
	cost_label.text = "$" + NumberFormatter.format_large_number(cost)
	
	# 구매 가능 여부에 따른 버튼 상태
	purchase_button.disabled = !_can_afford(cost)

func _get_current_level() -> int:
	match upgrade_category:
		"mining":
			return MiningManager.mining_upgrades[upgrade_name]
		"adventure":
			return AdventureManager.adventure_upgrades[upgrade_name]
		_:
			return 0

func _get_upgrade_cost() -> float:
	match upgrade_category:
		"mining":
			return MiningManager.get_mining_upgrade_cost(upgrade_name)
		"adventure":
			return AdventureManager.get_adventure_upgrade_cost(upgrade_name)
		_:
			return 0.0

func _can_afford(cost: float) -> bool:
	return GameData.money >= cost

# 버튼 클릭 시 호출
func _on_purchase_pressed():
	var success = false
	
	match upgrade_category:
		"mining":
			success = MiningManager.purchase_mining_upgrade(upgrade_name)
		"adventure":
			success = AdventureManager.purchase_adventure_upgrade(upgrade_name)
	
	if success:
		_update_display()
		_show_purchase_effect()

func _show_purchase_effect():
	# 구매 시 시각적 효과
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

# 돈 변경 시 UI 업데이트
func _on_money_changed(new_amount: float):
	_update_display()

# 업그레이드 구매 시 UI 업데이트 (다른 곳에서 구매한 경우도 대응)
func _on_mining_upgrade_purchased(purchased_upgrade: String, new_level: int):
	if upgrade_category == "mining" and purchased_upgrade == upgrade_name:
		_update_display()

func _on_adventure_upgrade_purchased(purchased_upgrade: String, new_level: int):
	if upgrade_category == "adventure" and purchased_upgrade == upgrade_name:
		_update_display()
