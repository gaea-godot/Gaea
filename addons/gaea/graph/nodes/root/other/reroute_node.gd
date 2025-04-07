@tool
extends GaeaGraphNode

const _RerouteResource = preload("uid://bgqqucap4kua4")
const _Slot = preload("uid://dgb4blornaq38")
var slot: _Slot
var icon_opacity: float = 0.5
const FADE_ANIMATION_LENGTH_SEC = 0.3

func initialize() -> void:
	print("initialize")
	if not is_instance_valid(resource):
		print("Invalid resource")
		return
	resource.node = self

	var slot_resource = GaeaNodeSlot.new()
	slot_resource.left_enabled = true
	slot_resource.left_type = resource.type
	slot_resource.right_enabled = true
	slot_resource.right_type = resource.type
	slot = slot_resource.get_node(self, 0)
	add_child(slot)
	
	var color = GaeaGraphNode.get_color_from_type(resource.type)
	set_slot(0,
		true, resource.type, color,
		true, resource.type, color,
	)
	
	set_slot_custom_icon_right(0, GaeaGraphNode.get_icon_from_type(resource.type))
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func update_slot() -> void:
	slot.left_type = resource.type
	slot.right_type = resource.type
	set_slot_type_left(0, resource.type)
	set_slot_type_right(0, resource.type)



func get_save_data() -> Dictionary:
	var data = super()
	return data


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
	var editor_scale = EditorInterface.get_editor_scale()
	var offset = Vector2(0, -16 * editor_scale)
	var drag_bg_color = get_theme_color(&"drag_background", &"VSRerouteNode");
	var circle_bg_color = Color(drag_bg_color, 1 if selected else icon_opacity)
	draw_circle(get_size() * 0.5 + offset, 16 * editor_scale, circle_bg_color, true, -1, true)

	var icon = EditorInterface.get_editor_theme().get_icon(&"ToolMove", &"EditorIcons")
	var icon_offset = - icon.get_size() * 0.5 + get_size() * 0.5 + offset
	draw_texture(icon, icon_offset, Color(1, 1, 1, 1 if selected else icon_opacity))



func _on_mouse_entered():
	print("_on_mouse_entered")
	var tween = create_tween()
	icon_opacity = 0.0
	tween.tween_property(self, "icon_opacity", 1.0, FADE_ANIMATION_LENGTH_SEC)

func _on_mouse_exited():
	print("_on_mouse_exited")
	var tween = create_tween()
	icon_opacity = 1.0
	tween.tween_property(self, "icon_opacity", 0.0, FADE_ANIMATION_LENGTH_SEC)
