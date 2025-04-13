@tool
extends MarginContainer

@export_group("Left", "left")
@export var left_enabled: bool = true:
	set(new_value):
		left_enabled = new_value
		_set_side_label_property(&"left", &"visible", new_value)
		if is_node_ready():
			graph_node.set_slot_enabled_left(idx, new_value)
@export var left_type: GaeaGraphNode.SlotTypes:
	set(new_value):
		left_type = new_value
		if is_node_ready():
			graph_node.set_slot_type_left(idx, new_value)
			graph_node.set_slot_color_left(idx, GaeaEditorSettings.get_configured_color_for_slot_type(new_value))
			graph_node.set_slot_custom_icon_left(idx, GaeaEditorSettings.get_configured_icon_for_slot_type(new_value))
@export var left_label: String = "":
	set(new_value):
		left_label = new_value
		_set_side_label_property(&"left", &"text", new_value)

@export_group("Right", "right")
@export var right_enabled: bool = true:
	set(new_value):
		right_enabled = new_value
		_set_side_label_property(&"right", &"visible", new_value)
		if is_node_ready():
			graph_node.set_slot_enabled_right(idx, new_value)
@export var right_type: GaeaGraphNode.SlotTypes:
	set(new_value):
		right_type = new_value
		if is_node_ready():
			graph_node.set_slot_type_right(idx, new_value)
			graph_node.set_slot_color_right(idx, GaeaEditorSettings.get_configured_color_for_slot_type(new_value))
			graph_node.set_slot_custom_icon_right(idx, GaeaEditorSettings.get_configured_icon_for_slot_type(new_value))
@export var right_label: String = "":
	set(new_value):
		right_label = new_value
		_set_side_label_property(&"right", &"text", new_value)

## Reference to the [GaeaGraphNode] instance
var graph_node: GaeaGraphNode
## ID of the slot in the [GaeaGraphNode].
var idx: int


@warning_ignore_start("unused_private_class_variable")
@onready var _left_label: RichTextLabel = %LeftLabel
@onready var _right_label: RichTextLabel = %RightLabel
@warning_ignore_restore("unused_private_class_variable")
@onready var toggle_preview_button: TextureButton = %TogglePreviewButton


func initialize(_graph_node: GaeaGraphNode, _idx: int) -> void:
	graph_node = _graph_node
	idx = _idx


func _ready() -> void:
	# On Godot load this can be null for some reasons
	if graph_node == null:
		return

	if not graph_node.is_node_ready():
		await graph_node.ready

	toggle_preview_button.texture_normal = get_theme_icon(&"GuiVisibilityHidden", &"EditorIcons")
	toggle_preview_button.texture_pressed = get_theme_icon(&"GuiVisibilityVisible", &"EditorIcons")
	toggle_preview_button.toggle_mode = true

	graph_node.set_slot(
		idx,
		left_enabled, left_type, GaeaEditorSettings.get_configured_color_for_slot_type(left_type),
		right_enabled, right_type, GaeaEditorSettings.get_configured_color_for_slot_type(right_type),
		GaeaEditorSettings.get_configured_icon_for_slot_type(left_type),
		GaeaEditorSettings.get_configured_icon_for_slot_type(right_type),
	)

	for side in [&"left", &"right"]:
		_set_side_label_property(side, &"visible", get(&"%s_enabled" % side))
		_set_side_label_property(side, &"text", get(&"%s_label" % side))


func _set_side_label_property(side: StringName, property: StringName, value: Variant):
	assert(side in [&"left", &"right"], "Invalid side given, should be &\"left\" or &\"right\"")
	var label = get(&"_%s_label" % side)
	if is_instance_valid(label) and label.is_inside_tree():
		label.set(property, value)
