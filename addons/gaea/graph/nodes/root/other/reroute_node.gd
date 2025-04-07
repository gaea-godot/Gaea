@tool
extends GaeaGraphNode

const _RerouteResource = preload("uid://bgqqucap4kua4")
const _Slot = preload("uid://dgb4blornaq38")
var slot: _Slot
var tween: Tween



var icon_opacity: float = 0.0:
	set(new_value):
		icon_opacity = new_value
		queue_redraw()

func initialize() -> void:
	if not is_instance_valid(resource):
		print("Invalid resource")
		return
	resource.node = self
	
	var titlebar_hbox = get_titlebar_hbox()
	var titlebar_label = titlebar_hbox.get_child(0)
	titlebar_label.hide()
	
	var slot_size = Vector2(32, 32) * EditorInterface.get_editor_scale()
	titlebar_hbox.set_custom_minimum_size(slot_size)
	titlebar_hbox.mouse_entered.connect(set_icon_opacity.bind(1.0))
	titlebar_hbox.mouse_exited.connect(set_icon_opacity.bind(0.0))

	var slot_area = Control.new()
	slot_area.set_custom_minimum_size(slot_size)
	slot_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(slot_area)

	add_theme_constant_override("port_h_offset", size.x * 0.5)

	var color = GaeaGraphNode.get_color_from_type(resource.type)
	set_slot(0,
		true, resource.type, color,
		true, resource.type, color,
	)
	set_slot_custom_icon_right(0, GaeaGraphNode.get_icon_from_type(resource.type))
	



func update_slot() -> void:
	slot.left_type = resource.type
	slot.right_type = resource.type
	set_slot_type_left(0, resource.type)
	set_slot_type_right(0, resource.type)



func get_save_data() -> Dictionary:
	var data = super()
	return data


func _draw_port(slot_index: int, pos: Vector2i, left: bool, color: Color) -> void:
	var port_icon = get_slot_custom_icon_right(slot_index)
	if not is_instance_valid(port_icon):
		port_icon = get_theme_icon(&"port", &"GraphNode")
	var icon_offset  = - port_icon.get_size() * 0.5
	var editor_scale = EditorInterface.get_editor_scale()
	var texture_rect = Rect2(
		Vector2(pos) + icon_offset * editor_scale,
		port_icon.get_size() * editor_scale
	)
	draw_texture_rect(port_icon, texture_rect, false, color)



func _draw() -> void:
	var opacity = 1.0 if selected else icon_opacity
	if is_zero_approx(opacity):
		return

	var editor_scale = EditorInterface.get_editor_scale()
	var offset = Vector2(0, -16 * editor_scale)
	var drag_bg_color = get_theme_color(&"drag_background", &"VSRerouteNode");
	var circle_bg_color = Color(drag_bg_color, opacity)
	draw_circle(get_size() * 0.5 + offset, 16 * editor_scale, circle_bg_color, true, -1, true)

	var icon = EditorInterface.get_editor_theme().get_icon(&"ToolMove", &"EditorIcons")
	var icon_offset = - icon.get_size() * 0.5 + get_size() * 0.5 + offset
	draw_texture(icon, icon_offset, Color(1, 1, 1, opacity))


func set_icon_opacity(value: float):
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "icon_opacity", value, 0.3)
