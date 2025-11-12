@tool
@abstract
class_name GaeaNodeSetOp
extends GaeaNodeResource

enum Operation { UNION, INTERSECTION, COMPLEMENT, DIFFERENCE }

const OPERATION_SYMBOLS := {
	Operation.UNION: "∪",
	Operation.INTERSECTION: "∩",
	Operation.COMPLEMENT: "ᶜ",
	Operation.DIFFERENCE: "-"
}


func _get_description() -> String:
	match get_enum_selection(0):
		Operation.UNION:
			return """Merges [param A]-[param D].
Later grids override any cells from the previous grids when valid. (B overrides A, C overrides B, etc.)"""
		Operation.INTERSECTION:
			return """Returns the intersection between [param A]-[param D].
Later grids override any cells from the previous grids when valid. (B overrides A, C overrides B, etc.)"""
		Operation.COMPLEMENT:
			return "Returns the complement of [param A]."
		Operation.DIFFERENCE:
			return "Returns all the points of [param A] without those of [param B]."
	return ""


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	for operation: Operation in _get_enum_options(0).values():
		var item: GaeaNodeResource = get_script().new()
		var operation_name: String = Operation.find_key(operation).to_pascal_case()
		var symbol: String = OPERATION_SYMBOLS[operation]
		var tree_name := "%s (%s)" % [operation_name, symbol]
		item.set_tree_name_override(tree_name)
		item.set_default_enum_value_override(0, operation)
		items.append(item)

	return items


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	var operations := Operation.duplicate()
	if get_type() == GaeaValue.Type.MAP:
		operations.erase(operations.find_key(Operation.COMPLEMENT))
	return operations


func _get_arguments_list() -> Array[StringName]:
	match get_enum_selection(0):
		Operation.UNION, Operation.INTERSECTION:
			return [&"a", &"b", &"c", &"d"]
		Operation.COMPLEMENT:
			return [&"a"]
		Operation.DIFFERENCE:
			return [&"a", &"b"]
	return []


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return get_type()


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_display_name(output_name: StringName) -> String:
	match get_enum_selection(0):
		Operation.UNION:
			return "A ∪ B ∪ ..."
		Operation.INTERSECTION:
			return "A ∩ B ∩ ..."
		Operation.COMPLEMENT:
			return "Aᶜ"
		Operation.DIFFERENCE:
			return "A - B"
	return super(output_name)


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


# The generic Dictionary type here is expected, and the type will be updated in child classes.
func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.GridType:
	var grids: Array[GaeaValue.GridType] = []
	for arg in _get_arguments_list():
		var arg_grid: GaeaValue.GridType = _get_arg(arg, graph, pouch)
		if not arg_grid.is_empty():
			grids.append(arg_grid)

	var grid: GaeaValue.GridType = GaeaValue.get_default_value(_get_output_port_type(_output_port))

	if grids.is_empty():
		return grid

	match get_enum_selection(0):
		Operation.UNION:
			for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
				for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
					for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
						var cell: Vector3i = Vector3i(x, y, z)
						for subgrid: GaeaValue.GridType in grids:
							if subgrid.has(cell):
								grid.set_cell(cell, subgrid.get_cell(cell))
		Operation.INTERSECTION:
			for cell: Vector3i in grids.pop_front().get_cells():
				for subgrid: GaeaValue.GridType in grids:
					if not subgrid.has(cell):
						grid.erase(cell)
						break
					else:
						grid.set_cell(cell, subgrid.get_cell(cell))
		Operation.COMPLEMENT:
			for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
				for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
					for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
						var cell: Vector3i = Vector3i(x, y, z)
						if not grids.front().has(cell):
							grid.set_cell(cell, 1.0)
		Operation.DIFFERENCE:
			var grid_a: GaeaValue.GridType = grids.pop_front()
			for cell: Vector3i in grid_a.get_cells():
				for subgrid: GaeaValue.GridType in grids:
					if subgrid.has(cell):
						grid.erase(cell)
						break
					grid.set_cell(cell, grid_a.get_cell(cell))

	return grid
