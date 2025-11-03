@tool
class_name GaeaNodeMapRandomFilter
extends GaeaNodeRandomFilter
## Map version of [GaeaNodeRandomFilter].


func _get_description() -> String:
	return super().replace("sample", "map")


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP
