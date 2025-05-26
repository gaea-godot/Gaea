@tool
class_name GaeaNodeDataSetOp
extends GaeaNodeSetOp
## Data version of [GaeaNodeSetOp].


func _get_title() -> String:
	return "DataSetOp"


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var data: Dictionary[Vector3i, float]
	data.assign(super(output_port, area, graph))
	return data
