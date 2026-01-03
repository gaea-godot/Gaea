@tool
class_name GaeaInvalidScriptGraphNode
extends GaeaGraphNode
## The in-editor representation of [GaeaNodeInvalid].

var _edited_object: EditedObject

class EditedObject extends RefCounted:
	@export_category("Invalid Script Node Data")
	@export var resource_id: int
	@export var arguments: Dictionary = {}
	@export var position: Vector2i
	@export var salt: int
	@export var uid: String:
		set(value):
			uid = value
			is_script_valid = GaeaNodeResource.is_valid_node_resource(value)
			if is_script_valid.is_empty():
				is_script_valid = "Yes, press the reload button above to reload the graph."
			else:
				is_script_valid = "No: %s" % is_script_valid
	@export_tool_button("Reload graph", "Reload")
	var reload_graph_action: Callable
	@export_multiline var is_script_valid: String = ""
	@export_category("RefCounted")

	func _init(node: GaeaInvalidScriptGraphNode) -> void:
		resource_id = node.resource.id
		reload_graph_action = node.reload_graph
		for property in get_property_list():
			var property_name: StringName = StringName(property.name)
			if node.resource._saved_data.has(property_name):
				set(property_name, node.resource._saved_data.get(property_name))


	func _validate_property(property: Dictionary) -> void:
		if property.name == &"resource_id" or property.name == &"is_script_valid":
			property.usage += PROPERTY_USAGE_READ_ONLY


func _on_added() -> void:
	super()

	var editor_interface = Engine.get_singleton("EditorInterface")
	var titlebar: HBoxContainer = get_titlebar_hbox()

	var spacer: Control = titlebar.add_spacer(false)
	spacer.custom_minimum_size.x += 5

	var edit_properties_button := Button.new()
	edit_properties_button.icon = editor_interface.get_editor_theme().get_icon(&"Edit", &"EditorIcons")
	edit_properties_button.tooltip_text = "Press to edit node properties."
	edit_properties_button.pressed.connect(_on_edit_properties_button_pressed)
	titlebar.add_child(edit_properties_button)

	var inspector: EditorInspector = EditorInterface.get_inspector()
	inspector.property_edited.connect(_on_edit_properties_changed)


func _on_edit_properties_button_pressed() -> void:
	var inspector: EditorInspector = EditorInterface.get_inspector()
	if resource is GaeaNodeInvalidScript:
		_edited_object = EditedObject.new(self)
		inspector.edit(_edited_object)


func _on_edit_properties_changed(property: StringName) -> void:
	var inspector: EditorInspector = EditorInterface.get_inspector()
	if inspector.get_edited_object() != _edited_object:
		return
	if resource is GaeaNodeInvalidScript:
		resource._saved_data.set(property, _edited_object.get(property))
		graph_edit.graph.set_node_data_value(resource.id, property, _edited_object.get(property))
		if property == &"position":
			position_offset = _edited_object.position


func reload_graph():
	var graph: GaeaGraph = graph_edit.graph
	graph.re_initialize_resource(resource.id)
	if not graph._resources.get(resource.id) is GaeaNodeInvalidScript:
		var inspector: EditorInspector = EditorInterface.get_inspector()
		if inspector.property_edited.is_connected(_on_edit_properties_changed):
			inspector.property_edited.disconnect(_on_edit_properties_changed)
		graph_edit.unpopulate()
		graph_edit.populate(graph)
		inspector.edit.call_deferred(graph)
