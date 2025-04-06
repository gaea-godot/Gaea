@tool
extends MarginContainer


@export_group("Left", "left")
@export var left_enabled: bool = true:
	set(new_value):
		left_enabled = new_value
		_set_side_label_property(&"left", &"visible", new_value)
@export var left_type: GaeaGraphNode.SlotTypes
@export var left_label: String = "":
	set(new_value):
		left_label = new_value
		_set_side_label_property(&"left", &"text", new_value)
@export_group("Right", "right")
@export var right_enabled: bool = true:
	set(new_value):
		right_enabled = new_value
		_set_side_label_property(&"right", &"visible", new_value)
@export var right_type: GaeaGraphNode.SlotTypes
@export var right_label: String = "":
	set(new_value):
		right_label = new_value
		_set_side_label_property(&"right", &"text", new_value)


var from_node: GraphNode

@warning_ignore_start("unused_private_class_variable")
@onready var _left_label: RichTextLabel = %LeftLabel
@onready var _right_label: RichTextLabel = %RightLabel
@warning_ignore_restore("unused_private_class_variable")
@onready var toggle_preview_button: TextureButton = %TogglePreviewButton


func _ready() -> void:
	var _maybe_graph_node: Node = get_parent()
	if _maybe_graph_node is not GraphNode:
		return

	var _graph_node: GraphNode = _maybe_graph_node

	toggle_preview_button.texture_normal = get_theme_icon(&"GuiVisibilityHidden", &"EditorIcons")
	toggle_preview_button.texture_pressed = get_theme_icon(&"GuiVisibilityVisible", &"EditorIcons")
	toggle_preview_button.toggle_mode = true

	if not _graph_node.is_node_ready():
		await _graph_node.ready
	var parent: Node = get_parent()
	var idx: int = get_index()
	if parent != owner and parent.get_parent() == owner:
		idx = parent.get_index()


	_graph_node.set_slot(
		idx,
		left_enabled, left_type, GaeaGraphNode.get_color_from_type(left_type),
		right_enabled, right_type, GaeaGraphNode.get_color_from_type(right_type),
	)

	for side in [&"left", &"right"]:
		_set_side_label_property(side, &"visible", get(&"%s_enabled" % side))
		_set_side_label_property(side, &"text", get(&"%s_label" % side))


func _set_side_label_property(side: StringName, property: StringName, value: Variant):
	assert(side in [&"left", &"right"], "Invalid side given, should be &\"left\" or &\"right\"")
	var label = get(&"_%s_label" % side)
	if is_instance_valid(label) and label.is_inside_tree():
		label.set(property, value)
