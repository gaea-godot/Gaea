@tool
extends HBoxContainer



@export_group("Left", "left")
@export var left_enabled: bool = true
@export var left_type: GaeaGraphNode.SlotTypes
@export var left_label: String = ""
@export_group("Right", "right")
@export var right_enabled: bool = true
@export var right_type: GaeaGraphNode.SlotTypes
@export var right_label: String = ""

var from_node: GraphNode

@onready var _left_label: Label = $LeftLabel
@onready var _right_label: Label = $RightLabel
@onready var toggle_preview_button: TextureButton = $TogglePreviewButton


func _ready() -> void:
	var _graph_node: Node = get_parent()
	if _graph_node is not GraphNode:
		return


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
		GaeaGraphNode.get_icon_from_type(left_type), GaeaGraphNode.get_icon_from_type(right_type),
	)

	if left_enabled:
		_left_label.text = left_label
	if right_enabled:
		_right_label.text = right_label
