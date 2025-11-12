@tool
class_name GaeaNodeInput
extends GaeaNodeResource
## Returns different input variables.

enum InputVar { WORLD_SIZE, AREA_SIZE, AREA_POSITION, AREA_END }


func _get_title() -> String:
	return "Input"


func _get_description() -> String:
	match get_enum_selection(0):
		InputVar.WORLD_SIZE:
			return "Outputs the [param world_size] parameter in the generator's inspector."
		InputVar.AREA_SIZE:
			return "Outputs the size of the area being currently generated."
		InputVar.AREA_POSITION:
			return "Outputs the position of the area being currently generated."
		InputVar.AREA_END:
			return "Outputs the bottom right corner position of the area being currently generated."
	return super()


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	for input_type in InputVar.values():
		var item: GaeaNodeResource = get_script().new()
		item.set_default_enum_value_override(0, input_type)
		item.set_tree_name_override(InputVar.find_key(input_type).to_pascal_case())
		items.append(item)

	return items


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_enum_idx: int) -> Dictionary:
	return InputVar


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_enum_option_icon(_enum_idx: int, option_value: int) -> Texture:
	return GaeaValue.get_display_icon(_get_type_of_input(option_value))


func _get_output_ports_list() -> Array[StringName]:
	return [&"value"]


func _get_arguments_list() -> Array[StringName]:
	return []


func _get_overridden_output_port_idx(_output_name: StringName) -> int:
	return 0


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return _get_type_of_input(get_enum_selection(0))


func _get_type_of_input(input: InputVar) -> GaeaValue.Type:
	match input:
		InputVar.WORLD_SIZE:
			return GaeaValue.Type.VECTOR3I
		InputVar.AREA_SIZE, InputVar.AREA_POSITION, InputVar.AREA_END:
			return GaeaValue.Type.VECTOR3
		_:
			return GaeaValue.Type.NULL


func _get_data(_output_port: StringName, _graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	match get_enum_selection(0):
		InputVar.WORLD_SIZE:
			return pouch.settings.world_size
		InputVar.AREA_SIZE:
			return pouch.area.size
		InputVar.AREA_POSITION:
			return pouch.area.position
		InputVar.AREA_END:
			return pouch.area.end

	return null
