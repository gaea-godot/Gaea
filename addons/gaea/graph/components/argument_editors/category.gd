@tool
class_name GaeaArgumentCategory
extends GaeaGraphNodeArgumentEditor

var arguments: Array[GaeaGraphNodeArgumentEditor]


func _configure() -> void:
	if is_part_of_edited_scene():
		return

	mouse_filter = MOUSE_FILTER_STOP if hint.get("collapsable", true) else MOUSE_FILTER_IGNORE


func set_label_text(new_text: String) -> void:
	self.title = new_text


func get_arg_value() -> bool:
	if super () != null:
		return super ()
	return self.folded


func set_arg_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_BOOL:
		return

	if not hint.get("collapsable", true):
		new_value = false

	self.folded = new_value
	_on_folding_changed(new_value)


func _on_folding_changed(is_folded: bool) -> void:
	for argument_editor in arguments:
		if is_folded:
			for child in argument_editor.get_children():
				child.hide()
			argument_editor.custom_minimum_size.y = 0.0
			argument_editor.size.y = 0.0
		else:
			for child in argument_editor.get_children():
				child.show()
			argument_editor.custom_minimum_size.y = 32.0
			argument_editor.size.y = argument_editor.get_combined_minimum_size().y
			graph_node._update_arguments_visibility()
		graph_node.auto_shrink()
