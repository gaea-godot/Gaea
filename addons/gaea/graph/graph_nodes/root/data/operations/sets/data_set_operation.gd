@tool
class_name GaeaNodeDataSetOp
extends GaeaNodeSetOp
## Data version of [GaeaNodeSetOp].


func _get_title() -> String:
	return "DataSetOp"


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA
