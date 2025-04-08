@tool
extends GaeaGraphNode

const _RerouteResource = preload("uid://bgqqucap4kua4")

var tween: Tween
var type: GaeaGraphNode.SlotTypes = GaeaGraphNode.SlotTypes.NUMBER:
	set(new_value):
		if type != new_value:
			type = new_value
			_update_slots(new_value)


var icon_opacity: float = 0.0:
	set(new_value):
		icon_opacity = new_value
		queue_redraw()

func initialize() -> void:
	super()
	
	var titlebar_hbox = get_titlebar_hbox()
	var titlebar_label = titlebar_hbox.get_child(0)
	titlebar_label.hide()

	var slot_size = Vector2(32, 32) * EditorInterface.get_editor_scale()
	titlebar_hbox.set_custom_minimum_size(slot_size)
	titlebar_hbox.mouse_entered.connect(_set_icon_opacity.bind(1.0))
	titlebar_hbox.mouse_exited.connect(_set_icon_opacity.bind(0.0))

	_update_slots(type)

func _update_slots(type: GaeaGraphNode.SlotTypes):
	var color = GaeaGraphNode.get_color_from_type(type)
	set_slot(0,
		true, type, color,
		true, type, color,
	)
	set_slot_type_left(0, type)
	set_slot_type_right(0, type)
	set_slot_custom_icon_right(0, GaeaGraphNode.get_icon_from_type(type))

static func create_resource() -> GaeaNodeResource:
	return _RerouteResource.new()

func get_save_data() -> Dictionary:
	var data = super()
	data.type = type
	return data


func load_save_data(data: Dictionary) -> void:
	if data.has(&"type"):
		type = data.type
	super(data)

func _draw_port(slot_index: int, pos: Vector2i, left: bool, color: Color) -> void:
	if left:
		return
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


func _set_icon_opacity(value: float):
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "icon_opacity", value, 0.3)
