extends Node2D

func _ready() -> void:
	consume_fuel(10)
	take_damage(50)

func _process(delta: float) -> void:
	pass

func consume_fuel(value: int):
	$player.consume_fuel(value)

func take_damage(value: int):
	$player.take_damage(value)

func refill_fuel(value: int):
	$player.refill_fuel(value)

func refill_health(value: int):
	$player.refill_health(value)

func add_cash(value: int):
	$player.add_cash(value)

func spend_cash(value: int):
	$player.spend_cash(value)
