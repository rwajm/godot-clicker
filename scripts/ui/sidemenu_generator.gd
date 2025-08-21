extends Control

@onready var quantity_selector = $UpgradeVbox/MarginContainer/QuantitySelectorButton
@onready var upgrade_container = $UpgradeVbox/ScrollContainer/VBoxContainer

var purchase_quantity = 1
var purchase_quantities = [1, 10, 100]
var current_quantity_index = 0

func _ready():
	quantity_selector.pressed.connect(_on_quantity_selector_pressed)
	_setup_upgrade_items()

func _setup_upgrade_items():
	for child in upgrade_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	var upgrade_item_scene = preload("res://scenes/upgrade_item.tscn")
	
	# 발전기
	if not MineDefs.generators.is_empty():
		var generator_ids = MineDefs.generators.keys()
		#generator_ids.sort() #정렬(추후)
		
		for generator_id in generator_ids:
			var upgrade_item = upgrade_item_scene.instantiate()
			upgrade_container.add_child(upgrade_item)
			upgrade_item.setup_upgrade(generator_id)
			upgrade_item.set_purchase_quantity(purchase_quantity)

func _on_quantity_selector_pressed():
	current_quantity_index = (current_quantity_index + 1) % purchase_quantities.size()
	purchase_quantity = purchase_quantities[current_quantity_index]
	quantity_selector.text = "×%d" % purchase_quantity
	
	_update_all_upgrade_quantities()

func _update_all_upgrade_quantities():
	for child in upgrade_container.get_children():
		if child.has_method("set_purchase_quantity"):
			child.set_purchase_quantity(purchase_quantity)
