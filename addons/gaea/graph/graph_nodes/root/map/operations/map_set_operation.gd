@tool
class_name GaeaNodeMapSetOp
extends GaeaNodeSetOp
## Map version of [GaeaNodeSetOp]. Has no Complement node.


func _get_title() -> String:
	return "MapSetOp"


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_data(output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, GaeaMaterial]:
	var data: Dictionary[Vector3i, GaeaMaterial]
	data.assign(super(output_port, area, graph))
	return data
