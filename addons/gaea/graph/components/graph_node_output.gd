@tool
class_name GaeaGraphNodeOutput
extends MarginContainer


var resource: GaeaNodeSlotOutput
## Reference to the [GaeaGraphNode] instance
var graph_node: GaeaGraphNode
## ID of the slot in the [GaeaGraphNode].
var idx: int


@onready var _label: RichTextLabel = %RightLabel
@onready var toggle_preview_button: TextureButton = %TogglePreviewButton


func initialize(_graph_node: GaeaGraphNode, _idx: int) -> void:
	graph_node = _graph_node
	idx = _idx


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	if not graph_node.is_node_ready():
		await graph_node.ready

	_label.text = resource.name.capitalize()
	toggle_preview_button.texture_normal = get_theme_icon(&"GuiVisibilityHidden", &"EditorIcons")
	toggle_preview_button.texture_pressed = get_theme_icon(&"GuiVisibilityVisible", &"EditorIcons")
	toggle_preview_button.toggle_mode = true
	
	graph_node.set_slot_enabled_right(idx, true)
	graph_node.set_slot_type_right(idx, resource.type)
	graph_node.set_slot_color_right(idx, GaeaValue.get_color(resource.type))
	graph_node.set_slot_custom_icon_right(idx, GaeaValue.get_slot_icon(resource.type))
