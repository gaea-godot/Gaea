@tool
class_name GaeaGraphNode
extends GraphNode
## The in-editor representation of a [GaeaNodeResource] to be used in the Gaea bottom panel.

const _PreviewTexture = preload("res://addons/gaea/graph/components/preview_texture.gd")

## Emitted when connections to this node are updated.
signal connections_updated
## Emitted when this node is removed from the graph.
signal removed
signal remove_invalid_connections_requested

## The [GaeaNodeResource] this acts as an editor of.
@export var resource: GaeaNodeResource

## The currently associated generator.
var generator: GaeaGenerator
## List of connections that goes to this node from other nodes.
## Used by the generator during runtime. This list is updated
## from [method update_connections] method.
var connections: Array[Dictionary]
# Holds a cache of the generated titlebar styleboxes for each [enum GaeaValue.Type].
# Updated if the type's color changes.
static var _titlebar_styleboxes: Dictionary[GaeaValue.Type, Dictionary]
var _preview: _PreviewTexture
var _preview_container: VBoxContainer
var _finished_loading: bool = false: set = set_finished_loading, get = has_finished_loading
var _finished_rebuilding: bool = true: get = has_finished_rebuilding
var _editors: Dictionary[StringName, GaeaGraphNodeArgumentEditor]
var _enum_editors: Array[OptionButton]
var _last_category: GaeaArgumentCategory


func _ready() -> void:
	_on_added()

	if is_instance_valid(resource):
		set_tooltip_text("tooltip")
		if Engine.get_version_info().hex >= 0x040500 and not resource is GaeaNodeReroute:
			var script = resource.get_script()
			if is_instance_valid(script):
				var documentation_button := Button.new()
				var editor_interface = Engine.get_singleton("EditorInterface")
				documentation_button.icon = editor_interface.get_editor_theme().get_icon(&"HelpSearch", &"EditorIcons")
				documentation_button.flat = true
				get_titlebar_hbox().add_child(documentation_button)
				documentation_button.pressed.connect(_open_node_documentation)
				tree_exiting.connect(documentation_button.pressed.disconnect.bind(_open_node_documentation))

	connections_updated.connect(_update_arguments_visibility)
	removed.connect(_on_removed)


## Initializes the node with a preview if needed, a salt value and instantiates all the
## [GaeaGraphNodeArgumentEditor] and [GaeaGraphNodeOutput] nodes.
func _on_added() -> void:
	if not is_instance_valid(resource) or is_part_of_edited_scene():
		return

	resource.node = self
	resource.argument_list_changed.connect(_rebuild, CONNECT_DEFERRED)

	for enum_idx in resource.get_enums_count():
		var option_button: OptionButton = OptionButton.new()
		for option in resource.get_enum_options(enum_idx).values():
			option_button.add_item(resource.get_enum_option_display_name(enum_idx, option), option)
			option_button.set_item_icon(
				option_button.get_item_index(option),
				resource.get_enum_option_icon(enum_idx, option)
				)
		option_button.select(option_button.get_item_index(resource.get_enum_selection(enum_idx)))

		add_child(option_button)
		option_button.item_selected.connect(_on_enum_value_changed.bind(enum_idx, option_button))
		_enum_editors.append(option_button)

	await _rebuild()

	title = resource.get_title()
	if resource.salt == 0:
		resource.salt = randi()
		generator.data.set_node_data_value(resource.id, &"salt", resource.salt)


func _rebuild() -> void:
	if not has_finished_rebuilding():
		return
	_finished_rebuilding = false
	var selected_preview: StringName = &""

	if is_instance_valid(_preview):
		selected_preview = _preview.selected_output

	var saved_data := {}
	if _finished_loading:
		saved_data = generator.data.get_node_data(resource.id)
		resource.enum_selections = saved_data.get("enums", [])
	_editors.clear()

	_preview_container = null
	_preview = null

	for child in get_children():
		if child is OptionButton:
			continue
		child.queue_free()
		await child.tree_exited

	clear_all_slots()

	_add_slots.call_deferred()

	if _finished_loading:
		load_save_data.call_deferred(saved_data)
	_add_preview_container.call_deferred()
	remove_invalid_connections_requested.emit.call_deferred()
	_update_arguments_visibility.call_deferred()
	if selected_preview.length() > 0:
		_open_preview.call_deferred(selected_preview)

	_finished_rebuilding = true

	_set_titlebar()
	_last_category = null


func _add_slots() -> void:
	for argument in resource.get_arguments_list():
		_editors.set(argument, _add_argument_editor(argument))

	var preview_button_group: ButtonGroup = ButtonGroup.new()
	preview_button_group.allow_unpress = true

	for output in resource.get_output_ports_list():
		var slot := _add_output_slot(output)
		if is_instance_valid(slot):
			slot.get_toggle_preview_button().button_group = preview_button_group


func _add_argument_editor(for_arg: StringName) -> GaeaGraphNodeArgumentEditor:
	var type: GaeaValue.Type = resource.get_argument_type(for_arg)
	var scene: PackedScene = GaeaValue.get_editor_for_type(type)
	var node: GaeaGraphNodeArgumentEditor = scene.instantiate()
	add_child(node)
	if type == GaeaValue.Type.CATEGORY:
		_last_category = node
	elif is_instance_valid(_last_category):
		_last_category.arguments.append(node)
	node.initialize(
		self,
		resource.get_argument_type(for_arg),
		resource.get_argument_display_name(for_arg),
		resource.arguments.get(for_arg, resource.get_argument_default_value(for_arg)),
		resource.get_argument_hint(for_arg)
	)

	if resource.has_input_slot(for_arg):
		node.add_input_slot()
	node.argument_value_changed.connect(_on_argument_value_changed.bind(node, for_arg))
	return node


func _add_output_slot(for_output: StringName) -> GaeaGraphNodeOutput:
	if resource.get_overridden_output_port_idx(for_output) >= 0:
		var new_idx: int = resource.get_overridden_output_port_idx(for_output)
		if get_child_count() > new_idx:
			var type: GaeaValue.Type = resource.get_output_port_type(for_output)
			set_slot_enabled_right(new_idx, true)
			set_slot_type_right(new_idx, type)
			set_slot_color_right(new_idx, GaeaValue.get_color(type))
			set_slot_custom_icon_right(new_idx, GaeaValue.get_slot_icon(type))
			return null

	var node: GaeaGraphNodeOutput = preload("uid://cqpby5jyv71l0").instantiate()
	add_child(node)
	node.initialize(
		self,
		resource.get_output_port_type(for_output),
		resource.get_output_port_display_name(for_output)
	)
	if GaeaValue.has_preview(resource.get_output_port_type(for_output)):
		node.get_toggle_preview_button().show()

		if not is_instance_valid(_preview):
			_preview_container = VBoxContainer.new()
			_preview = _PreviewTexture.new()
			_preview.node = self
			generator.generation_finished.connect(_preview.update.unbind(1))

		node.get_toggle_preview_button().toggled.connect(_preview.toggle.bind(for_output).unbind(1))
	return node


func _get_output_slot(for_output: StringName) -> GaeaGraphNodeOutput:
	var overridden_idx: int = resource.get_overridden_output_port_idx(for_output)
	if overridden_idx >= 0:
		return get_child(overridden_idx)

	var idx = resource.get_enums_count() + resource.get_arguments_list().size()
	for output in resource.get_output_ports_list():
		if output == for_output:
			return get_child(idx)
		if resource.get_overridden_output_port_idx(output) == -1:
			idx += 1

	return null


func _add_preview_container() -> void:
	if is_instance_valid(_preview_container):
		add_child(_preview_container)
		_preview_container.add_child(_preview)
		_preview_container.hide()
		_preview.update()


func _open_preview(for_output: StringName) -> void:
	var slot = _get_output_slot(for_output)
	if is_instance_valid(slot):
		slot.get_toggle_preview_button().set_pressed(true)


func _set_titlebar() -> void:
	var type: GaeaValue.Type = resource.get_type()
	var titlebar: StyleBoxFlat
	var titlebar_selected: StyleBoxFlat
	if type != GaeaValue.Type.NULL:
		remove_theme_stylebox_override("titlebar")
		remove_theme_stylebox_override("titlebar_selected")
		if not _titlebar_styleboxes.has(type) or _titlebar_styleboxes.get(type).get("for_color", Color.TRANSPARENT) != resource.get_title_color():
			titlebar = get_theme_stylebox("titlebar", "GraphNode").duplicate()
			titlebar_selected = get_theme_stylebox("titlebar_selected", "GraphNode").duplicate()
			titlebar.bg_color = titlebar.bg_color.blend(Color(resource.get_title_color(), 0.3))
			titlebar_selected.bg_color = titlebar.bg_color
			_titlebar_styleboxes.set(type, {"titlebar": titlebar, "selected": titlebar_selected, "for_color": resource.get_title_color()})
		else:
			titlebar = _titlebar_styleboxes.get(type).get("titlebar")
			titlebar_selected = _titlebar_styleboxes.get(type).get("selected")
		add_theme_stylebox_override("titlebar", titlebar)
		add_theme_stylebox_override("titlebar_selected", titlebar_selected)


## Returns the current value set in the [GaeaGraphNodeArgumentEditor] for the argument of [param arg_name].
func get_arg_value(arg_name: StringName) -> Variant:
	var editor: GaeaGraphNodeArgumentEditor = _editors.get(arg_name, null)
	if is_instance_valid(editor):
		return editor.get_arg_value()
	return null


## Sets the [GaeaGraphNodeArgumentEditor] associated to the argument of [param arg_name] to [param value].
func _set_arg_value(arg_name: StringName, value: Variant) -> void:
	var editor: GaeaGraphNodeArgumentEditor = _editors.get(arg_name, null)
	if is_instance_valid(editor):
		editor.set_arg_value(value)


func _on_argument_value_changed(value: Variant, _node: GaeaGraphNodeArgumentEditor, arg_name: String) -> void:
	if _finished_loading:
		resource.set_argument_value(arg_name, value)
		generator.data.set_node_argument(resource.id, arg_name, value)
		if is_instance_valid(_preview):
			_preview.update()


func _on_enum_value_changed(option_idx: int, enum_idx: int, button: OptionButton) -> void:
	if _finished_loading:
		var value := button.get_item_id(option_idx)
		resource.set_enum_value(enum_idx, value)
		generator.data.set_node_enum(resource.id, enum_idx, value)
		if is_instance_valid(_preview):
			_preview.update()


# Makes argument editors invisible if there's a wire connected to their input slot.
func _update_arguments_visibility() -> void:
	var input_idx: int = -1
	for child in get_children():
		if not is_slot_enabled_left(child.get_index()):
			continue
		input_idx += 1

		if child is not GaeaGraphNodeArgumentEditor:
			continue

		if is_zero_approx(child.size.y):
			continue

		child.set_editor_visible(not connections.any(_is_connected_to.bind(input_idx)))

	auto_shrink()


func _on_removed() -> void:
	pass


## Emit [signal connections_updated].
func notify_connections_updated() -> void:
	connections_updated.emit()


func _is_connected_to(connection: Dictionary, idx: int) -> bool:
	return connection.to_port == idx and connection.to_node == name


## Resizes the node to its minimum possible size, and updates wire display accordingly.
func auto_shrink() -> void:
	size = get_combined_minimum_size()
	# This is used to force the wire to redraw at the correct location
	await get_tree().process_frame
	for i: int in get_child_count():
		slot_updated.emit.call_deferred(i)


## Loads data with the same format as seen in [method get_save_data].
func load_save_data(saved_data: Dictionary) -> void:
	if saved_data.has(&"position"):
		position_offset = saved_data.position

	if saved_data.has(&"enums"):
		for enum_idx: int in saved_data.get(&"enums").size():
			_enum_editors[enum_idx].select(
				_enum_editors[enum_idx].get_item_index(saved_data.get("enums")[enum_idx])
			)

	if saved_data.has(&"arguments"):
		var arguments = saved_data.get(&"arguments")
		for argument: StringName in resource.get_arguments_list():
			var editor: GaeaGraphNodeArgumentEditor = _editors.get(argument)
			if not is_instance_valid(editor):
				break

			if not arguments.has(argument):
				arguments.set(argument, resource.get_argument_default_value(argument))

			if arguments.get(argument) != null:
				editor.set_arg_value(arguments.get(argument))


	_finished_loading = true


func _get_tooltip(_at_position: Vector2) -> String:
	return resource.get_description()


func _make_custom_tooltip(for_text: String) -> Object:
	if for_text.length() == 0:
		return null

	var rich_text_label: RichTextLabel = RichTextLabel.new()
	rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	rich_text_label.bbcode_enabled = true
	rich_text_label.text = GaeaNodeResource.get_formatted_text(for_text)
	rich_text_label.text += "\n[right][b]ID: %s[/b][/right]" % resource.id
	rich_text_label.fit_content = true
	rich_text_label.custom_minimum_size.x = 256.0
	return rich_text_label


func _open_node_documentation():
	var script = resource.get_script()
	if not is_instance_valid(script):
		return

	var resource_class_name = (script as GDScript).get_global_name()
	var editor_interface = Engine.get_singleton("EditorInterface")
	var script_editor = editor_interface.get_script_editor()
	script_editor.goto_help("class_name:%s" % resource_class_name)


## Sets whether or not this node has finished its loading process.
func set_finished_loading(value: bool) -> void:
	_finished_loading = value


## Returns [code]true[/code] if this node has finished its loading process.
func has_finished_loading() -> bool:
	return _finished_loading


func has_finished_rebuilding() -> bool:
	return _finished_rebuilding


func _on_dragged(_from: Vector2, to: Vector2) -> void:
	generator.data.set_node_position(resource.id, to)
