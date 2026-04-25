extends Resource

class_name OreData

const OreTypes = preload("res://data/ore_type.gd")

@export var name: String
@export var type: OreTypes.OreType
@export var collectable: bool
@export var value: float
@export var weight: float
@export var spawn_chance: float
@export var min_optimal_depth: float
@export var max_optimal_depth: float
@export var min_drill_strenght: float
@export var explosive_chance: int
@export var explosive_damage: int
@export var carry_damage_per_second: int
@export var fuel_bonus: int
@export var health_bonus: int
