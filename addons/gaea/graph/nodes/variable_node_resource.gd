@tool
extends GaeaNodeResource
class_name GaeaVariableNodeResource


@export var type: Variant.Type
@export var hint: PropertyHint
@export var hint_string: String
@export var output_type: GaeaGraphNode.SlotTypes


func get_data(_passed_data:Array[Dictionary], _output_port: int, _area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)
	return generator_data.parameters.get(get_arg("name", null))


static func get_scene() -> PackedScene:
	return preload("res://addons/gaea/graph/nodes/variable_node.tscn")


func get_type() -> GaeaGraphNode.SlotTypes:
	match type:
		TYPE_FLOAT, TYPE_INT:
			return GaeaGraphNode.SlotTypes.NUMBER
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return GaeaGraphNode.SlotTypes.VECTOR2
		TYPE_BOOL:
			return GaeaGraphNode.SlotTypes.BOOL
		TYPE_OBJECT:
			if hint_string == "GaeaMaterial":
				return GaeaGraphNode.SlotTypes.TILE_INFO
			elif hint_string == "GaeaMaterialGradient":
				return GaeaGraphNode.SlotTypes.GRADIENT
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return GaeaGraphNode.SlotTypes.VECTOR3
	return GaeaGraphNode.SlotTypes.NULL


func get_icon() -> Texture2D:
	match type:
		TYPE_FLOAT:
			return preload("../../assets/types/float.svg")
		TYPE_INT:
			return preload("../../assets/types/int.svg")
		TYPE_VECTOR2:
			return preload("../../assets/types/vec2.svg")
		TYPE_VECTOR2I:
			return preload("../../assets/types/vec2i.svg")
		TYPE_BOOL:
			return preload("../../assets/types/bool.svg")
		TYPE_OBJECT:
			if hint_string == "GaeaMaterial":
				return preload("../../assets/types/material.svg")
			elif hint_string == "GaeaMaterialGradient":
				return preload("../../assets/types/material_gradient.svg")
		TYPE_VECTOR3:
			return preload("../../assets/types/vec3.svg")
		TYPE_VECTOR3I:
			return preload("../../assets/types/vec3i.svg")
	return null
