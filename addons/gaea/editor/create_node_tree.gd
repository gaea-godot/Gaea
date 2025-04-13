@tool
extends Tree


signal node_selected_for_creation(resource: GaeaNodeResource)
signal special_node_selected_for_creation(id: StringName)

const NODES_FOLDER_PATH: String = "res://addons/gaea/graph/nodes/root/"

@export var description_label: RichTextLabel


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	populate()


func populate() -> void:
	clear()
	var root: TreeItem = create_item()
	hide_root = true
	var tree_dictionary: Dictionary = _populate_dict_with_files(NODES_FOLDER_PATH, {})
	tree_dictionary["Special"] = {
		"Frame": &"frame"
	}
	if not GaeaProjectSettings.get_custom_nodes_path().is_empty():
		tree_dictionary = _populate_dict_with_files(GaeaProjectSettings.get_custom_nodes_path(), tree_dictionary)
	_populate_from_dictionary(tree_dictionary, root)
	root.set_collapsed_recursive(true)
	root.set_collapsed(false)


func _populate_from_dictionary(dictionary: Dictionary, parent_item: TreeItem) -> void:
	for key: String in dictionary:
		var tree_item: TreeItem = create_item(parent_item)
		tree_item.set_text(0, key)

		if dictionary.get(key) is Dictionary:
			_populate_from_dictionary(dictionary.get(key), tree_item)
		else:
			var value: Variant = dictionary.get(key)
			tree_item.set_metadata(0, value)
			if value is GaeaNodeResource:
				tree_item.set_text(0, value.title)
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
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".tres"):
			file_name = dir.get_next()
			continue

		#var tree_item: TreeItem = create_item(parent_item)
		#tree_item.set_text(0, file_name.get_basename().capitalize())

		var tree_name: String = file_name.get_basename().capitalize()

		var file_path = folder_path + file_name
		if dir.current_is_dir():
			_populate_dict_with_files(file_path + "/", dict.get_or_add(tree_name, {}))

		if file_name.ends_with(".tres"):
			var resource: Resource = load(file_path)
			if resource is GaeaNodeResource:
				tree_name = resource.title
				dict.get_or_add(file_name, resource)


		file_name = dir.get_next()

	return dict


func _on_item_activated() -> void:
	var item: TreeItem = get_selected()
	if item.get_metadata(0) is GaeaNodeResource:
		node_selected_for_creation.emit(item.get_metadata(0).duplicate())
	elif item.get_metadata(0) is StringName:
		special_node_selected_for_creation.emit(item.get_metadata(0))


func _on_create_button_pressed() -> void:
	_on_item_activated()


func _on_item_selected() -> void:
	var item: TreeItem = get_selected()
	if item.get_metadata(0) is GaeaNodeResource:
		description_label.set_text(GaeaNodeResource.get_formatted_text(item.get_metadata(0).description))
	elif item.get_metadata(0) is StringName:
		match item.get_metadata(0):
			&"frame": description_label.set_text("A rectangular area for better organziation.")


func _on_search_bar_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		get_root().set_collapsed_recursive(true)
		get_root().collapsed = false
		deselect_all()
		return

	var item: TreeItem = get_root().get_next_in_tree()
	var first_item_found: bool = false
	item.collapsed = true

	while item.get_next_in_tree() != null:
		item = item.get_next_in_tree()
		if item.get_text(0).to_lower().contains(new_text.to_lower()):
			item.uncollapse_tree()
			if not first_item_found:
				scroll_to_item(item, true)
				item.select(0)
				first_item_found = true

	ensure_cursor_is_visible()
