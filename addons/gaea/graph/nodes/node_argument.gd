@tool
class_name GaeaNodeArgument
extends Resource

enum Type {
	FLOAT,
	INT,
	VECTOR2,
	VARIABLE_NAME, ## Used for VariableNodes.
	RANGE, ## Dictionary holding 2 keys: min and max.
	BITMASK, ## Int representing a bitmask.
	CATEGORY, ## For visual separation, doesn't get saved.
	BITMASK_EXCLUSIVE, ## Same as bitmask but only one bit can be active at once.
	FLAGS, ## Same interface as bitmask, but returns an Array of flags.
	BOOLEAN,
	VECTOR3,
	NEIGHBOR,
	RULES
}

@export var type: Type:
	set(value):
		type = value
		notify_property_list_changed()
@export var name: StringName
@export_storage var default_value: Variant
@export var hint: Dictionary[String, Variant]
@export_group("Slots")
@export var disable_input_slot: bool = false
@export var add_output_slot: bool = false

var value: Variant


func get_arg_node(_graph_node: GaeaGraphNode, _idx: int) -> GaeaGraphNodeParameter:
	var scene: PackedScene = get_scene_from_type(type)
	if not is_instance_valid(scene):
		return null

	var node: GaeaGraphNodeParameter = scene.instantiate()
	node.initialize(_graph_node, _idx)
	if disable_input_slot:
		node.add_input_slot = false
	node.add_output_slot = add_output_slot
	node.resource = self

	return node


func get_arg_name() -> StringName:
	return name


static func get_scene_from_type(for_type: Type) -> PackedScene:
	match for_type:
		Type.FLOAT, Type.INT:
			return preload("res://addons/gaea/graph/components/inputs/number_parameter.tscn")
		Type.VECTOR2:
			return preload("res://addons/gaea/graph/components/inputs/vector2_parameter.tscn")
		Type.VARIABLE_NAME:
			return preload("res://addons/gaea/graph/components/inputs/variable_name_parameter.tscn")
		Type.RANGE:
			return preload("res://addons/gaea/graph/components/inputs/range_parameter.tscn")
		Type.BITMASK, Type.BITMASK_EXCLUSIVE, Type.FLAGS:
			return preload("res://addons/gaea/graph/components/inputs/bitmask_parameter.tscn")
		Type.CATEGORY:
			return preload("res://addons/gaea/graph/components/inputs/category.tscn")
		Type.BOOLEAN:
			return preload("res://addons/gaea/graph/components/inputs/boolean_parameter.tscn")
		Type.VECTOR3:
			return preload("res://addons/gaea/graph/components/inputs/vector3_parameter.tscn")
		Type.NEIGHBOR:
			return preload("res://addons/gaea/graph/components/inputs/neighbor_parameter.tscn")
		Type.RULES:
			return preload("res://addons/gaea/graph/components/inputs/rules_parameter.tscn")
	return null


static func get_slot_type_equivalent(for_type: Type) -> GaeaGraphNode.SlotTypes:
	match for_type:
		Type.FLOAT, Type.INT:
			return GaeaGraphNode.SlotTypes.NUMBER
		Type.VECTOR2:
			return GaeaGraphNode.SlotTypes.VECTOR2
		Type.VECTOR3:
			return GaeaGraphNode.SlotTypes.VECTOR3
		Type.BOOLEAN:
			return GaeaGraphNode.SlotTypes.BOOL
		Type.RANGE:
			return GaeaGraphNode.SlotTypes.RANGE
		_:
			return GaeaGraphNode.SlotTypes.NULL


static func get_icon_for_type(for_type: Type) -> Texture2D:
	if for_type == Type.FLOAT:
		return preload("../../assets/types/float.svg")
	if for_type == Type.INT:
		return preload("../../assets/types/int.svg")
	return GaeaNodeResource.get_icon_for_slot_type(get_slot_type_equivalent(for_type))


func _validate_property(property: Dictionary) -> void:
	if property.name == "default_value":
		match type:
			Type.FLOAT:
				property.type = TYPE_FLOAT
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.INT:
				property.type = TYPE_INT
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.VECTOR2:
				property.type = TYPE_VECTOR2
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.RANGE:
				property.type = TYPE_DICTIONARY
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.BITMASK, Type.BITMASK_EXCLUSIVE:
				property.type = TYPE_INT
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
				property.hint = PROPERTY_HINT_LAYERS_2D_PHYSICS
			Type.BOOLEAN:
				property.type = TYPE_BOOL
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.FLAGS:
				property.type = TYPE_ARRAY
				property.hint = PROPERTY_HINT_TYPE_STRING
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
				property.hint_string = "%d:" % [TYPE_INT]
			Type.VECTOR3:
				property.type = TYPE_VECTOR3
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.NEIGHBOR:
				property.type = TYPE_ARRAY
				property.hint = PROPERTY_HINT_TYPE_STRING
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
				property.hint_string = "%d:" % [TYPE_VECTOR2I]

	if property.name == "hint" and type == Type.CATEGORY:
		property.usage = PROPERTY_USAGE_NONE
