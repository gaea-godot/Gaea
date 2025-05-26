@tool
class_name GaeaNodeToHeight
extends GaeaNodeResource
## Transforms [param reference_data] into a new data grid where the height of each column is determined by [param height_offset] + ([param reference_data] * [param displacement_intensity])
##
## For each cell in [param reference_data]'s [param reference_y] row, it'll get the [code]float[/code] value,
## multiply it by [param displacement_intensity] and add [param height_offset] to it. This will be
## the column's height, and every cell below that height (inclusive) will be full while every cell above
## will be empty.[br][br]
## This functions to create a heightmap, which can be used to create 2D side-view or
## 3D terrain.[br][br]
## [b]Note: Keep in mind the y axis in Godot is negative for up in 2D and down in 3D.[/b]

enum Type {
	TYPE_2D, ## Referenced data will only take into account the x coordinate of the cell.
	TYPE_3D ## Referenced data will take into account both the x and the z coordinates of the cell.
}


func _get_title() -> String:
	return "ToHeight"


func _get_description() -> String:
	var desc: String =  "Transforms [param reference_data] into a new data grid where the height of each column is determined by\
	[param height_offset] + ([param reference_data] * [param displacement_intensity]).\n"
	match get_enum_selection(0):
		Type.TYPE_2D:
			desc += "\nReferences all the x values of the [param reference_y] row."
		Type.TYPE_3D:
			desc += "\nReferences all the x,z values of the [param reference_y] row."
	return desc


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	for type in Type.values():
		var item: GaeaNodeToHeight = get_script().new()
		item.set_tree_name_override(_get_title() + _get_enum_option_display_name(0, type))
		item.set_default_enum_value_override(0, type)
		items.append(item)

	return items


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_enum_idx: int) -> Dictionary:
	return Type


func _get_enum_option_display_name(_enum_idx: int, option_value: int) -> String:
	return Type.find_key(option_value).trim_prefix("TYPE_")



func _get_arguments_list() -> Array[StringName]:
	return [&"reference_data", &"reference_y",
			&"height_offset", &"displacement_intensity",
			&"gradient_intensity"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"reference_data": return GaeaValue.Type.DATA
		&"gradient_intensity": return GaeaValue.Type.FLOAT
		_: return GaeaValue.Type.INT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"displacement_intensity": return 16
		&"gradient_intensity": return 1.0
	return super(arg_name)



func _get_output_ports_list() -> Array[StringName]:
	return [&"data"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var reference_data: Dictionary = _get_arg(&"reference_data", area, graph)
	var row: int = _get_arg(&"reference_y", area, graph)
	var height_offset: int = _get_arg(&"height_offset", area, graph)
	var displacement: int = _get_arg(&"displacement_intensity", area, graph)
	var gradient_intensity: float = _get_arg(&"gradient_intensity", area, graph)
	var data: Dictionary[Vector3i, float] = {}
	var type: Type = get_enum_selection(0) as Type

	var remap_offset: float = 0.0
	if not is_zero_approx(gradient_intensity):
		remap_offset = 100.0 / gradient_intensity

	var z_range: Array = [0] if (type == Type.TYPE_2D) else (_get_axis_range(Vector3i.AXIS_Z, area))
	for x in _get_axis_range(Vector3i.AXIS_X, area):
		if not reference_data.has(Vector3i(x, row, 0)):
			continue
		for z in z_range:
			var height: int = floor(reference_data[Vector3i(x, row, z)] * displacement + height_offset)
			for y in _get_axis_range(Vector3i.AXIS_Y, area):
				if y >= -height and type == Type.TYPE_2D:
					data[Vector3i(x, y, z)] = 1.0 if is_zero_approx(remap_offset) else remap(
						y, -height + remap_offset, -height, 0, 1.0
					)
				elif y <= height and type == Type.TYPE_3D:
					data[Vector3i(x, y, z)] = 1.0 if is_zero_approx(remap_offset) else remap(
						y, height, height - remap_offset, 1.0, 0.0
					)
	return data
