class_name MineClick
extends MineItem

func _init(id: String) -> void:
	super(id)

func trigger_click() -> float:
	if level > 0:
		return base_yield * level * current_yield_multiplier
	return 0.0
