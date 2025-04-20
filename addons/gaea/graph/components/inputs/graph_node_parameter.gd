@tool
@icon("../../../assets/parameter_editor.svg")
class_name GaeaGraphNodeParameterEditor
extends Control
## An editor inside [GaeaGraphNode]s to change values of arguments, or a simple input slot
## if there's no existing editor.
##
## This class can be extended to create editors for the different value types in Gaea.

## Emitted when the value is changed using the editor.
signal param_value_changed(new_value: Variant)

## The resource that holds the information of this node, such as [member GaeaNodeSlotParam.default_value]
## and [member GaeaNodeSlotParam.name], and others.
var resource: GaeaNodeSlotParam
## Reference to the [GaeaGraphNode] instance
var graph_node: GaeaGraphNode
## Index of the slot in the [GaeaGraphNode].
var slot_idx: int

@onready var _label: Label = $Label


## Sets the corresponding variables.
func initialize(for_graph_node: GaeaGraphNode, for_slot_idx: int) -> void:
	graph_node = for_graph_node
	slot_idx = for_slot_idx


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	if resource.default_value != null:
		set_param_value(resource.default_value)

	if not graph_node.is_node_ready():
		await graph_node.ready

	param_value_changed.connect(graph_node._on_param_value_changed.bind(self, resource.name))

	if GaeaValue.is_wireable(resource.type):
		graph_node.set_slot_enabled_left(slot_idx, true)
		graph_node.set_slot_type_left(slot_idx, resource.type)
		graph_node.set_slot_color_left(slot_idx, GaeaValue.get_color(resource.type))
		graph_node.set_slot_custom_icon_left(slot_idx, GaeaValue.get_slot_icon(resource.type))
	else:
		# This is required because without it the color of the slots after is OK but not the icon.
		# Probably a Godot issue.
		graph_node.set_slot_enabled_left(slot_idx, false)

	set_label_text(resource.name.capitalize())


## Override to return the value in the editor.
func get_param_value() -> Variant:
	return null


## Override to allow setting the value in the editor.
func set_param_value(_new_value: Variant) -> void:
	pass


## Set this parameter's name label text to [param new_text]
func set_label_text(new_text: String) -> void:
	_label.text = new_text


## Returns the current text in this parameter's name label.
func get_label_text() -> String:
	return _label.text


## If [param value] is [code]false[/code], hides everything in the editor except the name label.
func set_param_visible(value: bool) -> void:
	for child in get_children():
		if child == _label:
			continue
		child.set_visible(value)
