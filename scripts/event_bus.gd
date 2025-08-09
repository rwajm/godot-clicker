extends Node

# 공통 
signal money_changed(new_amount: float)
signal gems_changed(new_amount: int)

# 광산(클리커)
signal mine_clicked(amount: float)
signal mine_resource_generated(amount: float)
signal mine_upgrade_purchased(upgrade_id: String, new_level: int)
signal mine_generator_purchased(generator_id: String, new_count: int)
