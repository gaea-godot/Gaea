@tool
class_name GaeaGraphNodeOutput
extends MarginContainer
## An output slot inside a [GaeaGraphNode].

## Reference to the [GaeaGraphNode] instance
var graph_node: GaeaGraphNode
## Index of the slot in the [GaeaGraphNode].
var idx: int
var type: GaeaValue.Type

@onready var _label: RichTextLabel = %RightLabel
@onready var _toggle_preview_button: TextureButton = %TogglePreviewButton:
	get = get_toggle_preview_button


## Sets the corresponding variables.
func initialize(
	for_graph_node: GaeaGraphNode, for_type: GaeaValue.Type, display_name: String
) -> void:
	graph_node = for_graph_node
	type = for_type
	_label.text = display_name
	idx = get_index()

	_configure()


func _configure() -> void:
	if is_part_of_edited_scene():
		return

	if not graph_node.is_node_ready():
		await graph_node.ready

	_toggle_preview_button.texture_normal = get_theme_icon(&"GuiVisibilityHidden", &"EditorIcons")
	_toggle_preview_button.texture_pressed = get_theme_icon(&"GuiVisibilityVisible", &"EditorIcons")
	_toggle_preview_button.toggle_mode = true

	graph_node.set_slot_enabled_right(idx, true)
	graph_node.set_slot_type_right(idx, type)
	graph_node.set_slot_color_right(idx, GaeaValue.get_color(type))
	graph_node.set_slot_custom_icon_right(idx, GaeaValue.get_slot_icon(type))


## Returns the button used to toggle the preview for this output slot.
func get_toggle_preview_button() -> TextureButton:
	return _toggle_preview_button
