@tool
class_name GaeaCreateNodeTree
extends Tree

const NODES_FOLDER_PATH: String = "res://addons/gaea/graph/graph_nodes/root/"

@export var main_editor: GaeaMainEditor
@export var description_label: RichTextLabel
var tree_dictionary: Dictionary

var filters: Dictionary[StringName, Callable]


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	populate()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.is_command_or_control_pressed() and event.keycode == KEY_TAB:
			_select_next_visible(
				get_selected() if get_selected() != null else get_root(),
				1 if not event.is_shift_pressed() else -1
			)


func populate() -> void:
	clear()
	var root: TreeItem = create_item()
	hide_root = true
	tree_dictionary = _populate_dict_with_files(NODES_FOLDER_PATH, {})
	tree_dictionary["Special"] = {"Frame": &"frame"}
	if not GaeaProjectSettings.get_custom_nodes_path().is_empty():
		tree_dictionary = _populate_dict_with_files(
			GaeaProjectSettings.get_custom_nodes_path(), tree_dictionary
		)
	_populate_from_dictionary(tree_dictionary, root)
	root.set_collapsed_recursive(true)
	root.set_collapsed(false)


func _populate_from_dictionary(dictionary: Dictionary, parent_item: TreeItem) -> void:
	parent_item.set_selectable(0, false)
	for key: String in dictionary:
		var tree_item: TreeItem = create_item(parent_item)
		tree_item.set_text(0, key)

		if dictionary.get(key) is Dictionary:
			_populate_from_dictionary(dictionary.get(key), tree_item)
		else:
			var value: Variant = dictionary.get(key)
			tree_item.set_metadata(0, value)
			if value is GaeaNodeResource:
				tree_item.set_text(0, value.get_tree_name())
				tree_item.set_icon(0, value.get_icon())
				tree_item.set_icon_max_width(0, 16)


func _populate_dict_with_files(folder_path: String, dict: Dictionary) -> Dictionary:
	folder_path += ("/" if not folder_path.ends_with("/") else "")
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error(error_string(DirAccess.get_open_error()))
		return {}

	dir.list_dir_begin()
	var file_name := dir.get_next()
	var idx: int = 0
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".gd"):
			file_name = dir.get_next()
			continue

		idx += 1

		var tree_name: String = file_name.get_basename().capitalize()

		var file_path = folder_path + file_name
		if dir.current_is_dir():
			_populate_dict_with_files(file_path + "/", dict.get_or_add(tree_name, {}))

		if file_name.ends_with(".gd"):
			var script := load(file_path)
			if script is GDScript:
				var is_valid_node_resource := false
				var base_script: GDScript = script
				while is_instance_valid(base_script):
					base_script = base_script.get_base_script()
					if base_script == GaeaNodeResource:
						is_valid_node_resource = true
						break
				if is_valid_node_resource:
					var resource: GaeaNodeResource = script.new()
					if resource.is_available():
						var sub_idx: int = 0
						for item in resource.get_tree_items():
							sub_idx += 1
							dict.get_or_add(item.get_tree_name() + str(idx) + str(sub_idx), item)
		file_name = dir.get_next()

	dict.sort()
	return dict


func _on_item_activated() -> void:
	var item: TreeItem = get_selected()
	if not is_instance_valid(item):
		return
	main_editor.create_node_popup.hide()
	if item.get_metadata(0) is GaeaNodeResource:
		main_editor.node_selected_for_creation.emit(item.get_metadata(0))
	elif item.get_metadata(0) is StringName:
		main_editor.special_node_selected_for_creation.emit(item.get_metadata(0))


func _on_create_button_pressed() -> void:
	_on_item_activated()


func _on_item_selected() -> void:
	var item: TreeItem = get_selected()
	if item.get_metadata(0) is GaeaNodeResource:
		description_label.set_text(
			GaeaNodeResource.get_formatted_text(item.get_metadata(0).get_description())
		)
	elif item.get_metadata(0) is StringName:
		match item.get_metadata(0):
			&"frame":
				description_label.set_text("A rectangular area for better organziation.")


func _on_nothing_selected() -> void:
	description_label.set_text("")


func _on_search_bar_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		get_root().set_collapsed_recursive(true)
		get_root().collapsed = false
		deselect_all()
		remove_filter(&"text")
		apply_filters(false)
	else:
		get_root().set_collapsed_recursive(false)
		add_filter(
			(func(item: TreeItem, text: String) -> bool:
				return text.is_subsequence_ofn(item.get_text(0)) or text.is_empty()).bind(new_text),
				&"text"
		)


func filter_to_input_type(type: GaeaValue.Type) -> void:
	add_filter(
		(func(item: TreeItem, match_type: GaeaValue.Type) -> bool:
			if item.get_metadata(0) is not GaeaNodeResource:
				return false

			var node: GaeaNodeResource = item.get_metadata(0)
			for argument in node.get_arguments_list():
				if node.has_input_slot(argument) and GaeaValue.is_valid_connection(
					match_type, node.get_argument_type(argument)
				):
					return true

			return false).bind(type),
			&"type"
	)


func filter_to_output_type(type: GaeaValue.Type) -> void:
	add_filter(
		(func(item: TreeItem, match_type: GaeaValue.Type) -> bool:
			if item.get_metadata(0) is not GaeaNodeResource:
				return false

			var node: GaeaNodeResource = item.get_metadata(0)
			for argument in node.get_output_ports_list():
				if GaeaValue.is_valid_connection(
					node.get_output_port_type(argument), match_type
				):
					return true

			return false).bind(type),
			&"type"
	)


func add_filter(filter: Callable, id: StringName) -> void:
	filters[id] = filter
	apply_filters(true)


func remove_filter(id: StringName) -> void:
	filters.erase(id)


func apply_filters(scroll_to_first_found: bool) -> void:
	var item: TreeItem = get_root()
	var first_item_found: TreeItem = null

	while item.get_next_in_tree() != null:
		item = item.get_next_in_tree()
		var item_matched = filters.values().all(func(f: Callable) -> bool: return f.call(item))
		if item_matched and item.is_selectable(0):
			if first_item_found == null:
				first_item_found = item
			item.visible = true
			_show_parents_recursive(item)
		else:
			item.visible = false

	if first_item_found and scroll_to_first_found:
		scroll_to_item(first_item_found, true)
		first_item_found.select(0)
		ensure_cursor_is_visible()
	else:
		scroll_to_item(get_root(), true)
		deselect_all()


func _select_next_visible(from: TreeItem, direction: int = 1) -> void:
	if not is_instance_valid(from):
		return

	var item: TreeItem = (
		from.get_next_visible(true) if direction == 1 else from.get_prev_visible(true)
	)
	if not is_instance_valid(item):
		return

	while not item.is_selectable(0):
		item.set_collapsed_recursive(false)
		item = (item.get_next_visible(true) if direction == 1 else item.get_prev_visible(true))
	_show_parents_recursive(item)
	scroll_to_item(item)
	item.select(0)
	grab_focus()


func _show_parents_recursive(item: TreeItem) -> void:
	var parent_item: TreeItem = item.get_parent()
	while parent_item != null:
		parent_item.visible = true
		parent_item.set_collapsed_recursive(false)
		parent_item = parent_item.get_parent()


func _on_search_bar_text_submitted(_new_text: String) -> void:
	if get_selected() != null:
		_on_item_activated()
