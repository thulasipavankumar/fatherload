extends RefCounted
class_name GroundTile

var type: GroundTypes.GroundType
var ore: OreData = null

func _init(
	p_type: GroundTypes.GroundType = GroundTypes.GroundType.DIRT,
	p_ore: OreData = null
):
	type = p_type
	ore = p_ore
