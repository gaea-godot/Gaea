@tool
extends GaeaGraphNode

const _RerouteResource = preload("uid://bgqqucap4kua4")

var tween: Tween
var type: GaeaGraphNode.SlotTypes = GaeaGraphNode.SlotTypes.NUMBER:
	set(new_value):
		if type != new_value:
			type = new_value
			if not is_part_of_edited_scene():
				resource.title = "Reroute (%s)" % GaeaGraphNode.SlotTypes.find_key(new_value).capitalize()
			_update_slots()

var icon_opacity: float = 0.0:
	set(new_value):
		icon_opacity = new_value
		queue_redraw()

var has_no_input: bool = false:
	set(new_value):
		has_no_input = new_value
		queue_redraw()

#region init
func initialize() -> void:
	super()
	if not is_instance_valid(resource) or is_part_of_edited_scene():
		return

	resource.input_slots[0].left_enabled = true
	resource.input_slots[0].right_enabled = true
	connections_updated.connect(_validate_connections)

	var titlebar_hbox = get_titlebar_hbox()
	var titlebar_label = titlebar_hbox.get_child(0)
	titlebar_label.hide()

	var slot_size = Vector2(32, 32) * EditorInterface.get_editor_scale()
	titlebar_hbox.set_custom_minimum_size(slot_size)
	titlebar_hbox.mouse_entered.connect(_set_icon_opacity.bind(1.0))
	titlebar_hbox.mouse_exited.connect(_set_icon_opacity.bind(0.0))

	_update_slots()
	_validate_connections()


func _update_slots():
	var color = GaeaEditorSettings.get_configured_color_for_slot_type(type)
	set_slot(0, true, type, color, true, type, color)
	set_slot_type_left(0, type)
	set_slot_type_right(0, type)
	set_slot_custom_icon_right(0, GaeaEditorSettings.get_configured_icon_for_slot_type(type))
	if not is_part_of_edited_scene():
		resource.input_slots[0].left_type = type
		resource.input_slots[0].right_type = type
		resource.title = "Reroute (%s)" % GaeaGraphNode.SlotTypes.find_key(type).capitalize()
#endregion


#region Lifecycle
func on_removed() -> void:
	var graph_edit: GraphEdit = find_parent("GraphEdit")
	var input_connection: Dictionary = {}

	if connections.size() == 1:
		input_connection = connections[0]
		graph_edit.disconnection_request.emit(
			input_connection.from_node,
			input_connection.from_port,
			input_connection.to_node,
			input_connection.to_port,
		)

	for connection in graph_edit.connections:
		if connection.from_node == name and connection.from_port == 0:
			graph_edit.disconnection_request.emit(
				connection.from_node,
				connection.from_port,
				connection.to_node,
				connection.to_port,
			)
			if not input_connection.is_empty():
				graph_edit.connection_request.emit(
					input_connection.from_node,
					input_connection.from_port,
					connection.to_node,
					connection.to_port,
				)
#endregion


#region Save/Load
func get_save_data() -> Dictionary:
	var data = super()
	data.type = type
	return data


func load_save_data(data: Dictionary) -> void:
	if data.has(&"type"):
		type = data.type
	super(data)
#endregion


#region Display
func _draw_port(slot_index: int, pos: Vector2i, left: bool, color: Color) -> void:
	if left:
		return
	var center_pos = Vector2(pos)
	var editor_scale = EditorInterface.get_editor_scale()

	if has_no_input:
		draw_circle(center_pos, 10 * editor_scale, Color.ORANGE_RED, true, -1, true)

	var port_icon = get_slot_custom_icon_right(slot_index)
	if not is_instance_valid(port_icon):
		port_icon = get_theme_icon(&"port", &"GraphNode")
	var icon_offset = -port_icon.get_size() * 0.5

	draw_texture_rect(
		port_icon,
		Rect2(
			center_pos + icon_offset * editor_scale,
			port_icon.get_size() * editor_scale
		),
		false,
		color
	)


func _draw() -> void:
	var opacity = 1.0 if selected else icon_opacity
	if is_zero_approx(opacity):
		return

	var editor_scale = EditorInterface.get_editor_scale()
	var offset = Vector2(0, -16 * editor_scale)
	var drag_bg_color = get_theme_color(&"drag_background", &"VSRerouteNode")
	var circle_bg_color = Color(drag_bg_color, opacity)

	if selected:
		var selected_color = get_theme_color(&"selected_rim_color", &"VSRerouteNode")
		draw_circle(get_size() * 0.5 + offset, 18 * editor_scale, selected_color, true, -1, true)

	draw_circle(get_size() * 0.5 + offset, 16 * editor_scale, circle_bg_color, true, -1, true)

	var icon = EditorInterface.get_editor_theme().get_icon(&"ToolMove", &"EditorIcons")
	var icon_offset = -icon.get_size() * 0.5 + get_size() * 0.5 + offset
	draw_texture(icon, icon_offset, Color(1, 1, 1, opacity))


func _set_icon_opacity(value: float):
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "icon_opacity", value, 0.3)
#endregion


func _validate_connections():
	has_no_input = connections.size() == 0
