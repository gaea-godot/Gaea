@tool
class_name GaeaNodeSlotParam extends GaeaNodeSlot

#enum Mode {
#	SINGLE,
#	ARRAY,
#}

@export var name: StringName = &"":
	set(new_value):
		name = new_value
		_update_resource_name()
# For future PR to have multiple wire for a single param
#@export var mode: Mode = Mode.SINGLE:
#	set(new_value):
#		mode = new_value
#		_update_resource_name()
@export var type: GaeaValue.Type = GaeaValue.Type.FLOAT:
	set(new_value):
		type = new_value
		default_value = _property_get_revert(&"default_value")
		_update_resource_name()
		notify_property_list_changed()
@export var hint: Dictionary[String, Variant]
@export_storage var default_value: Variant = null


#region Inspector related virtual methods
func _property_can_revert(property: StringName) -> bool:
	match property:
		&"default_value":
			return true
	return super(property)


func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"default_value":
			return GaeaValue.get_default_value(type)
	return super(property)


func _validate_property(property: Dictionary) -> void:
	if property.name == "default_value" or property.name == "hint":
		GaeaValue.apply_property_type_hint(property, type)
#endregion


func get_node(_graph_node: GaeaGraphNode, _idx: int) -> Control:
	var scene: PackedScene = get_scene_from_type(type)
	var node: GaeaGraphNodeParameter = scene.instantiate()
	node.resource = self
	node.initialize(_graph_node, _idx)
	return node


static func get_scene_from_type(for_type: GaeaValue.Type) -> PackedScene:
	match for_type:
		GaeaValue.Type.FLOAT, GaeaValue.Type.INT:
			return preload("uid://dp7blnx7abb5e")
		GaeaValue.Type.VECTOR2:
			return preload("uid://rlocedi6g62i")
		GaeaValue.Type.VARIABLE_NAME:
			return preload("uid://bn8i1l4q13pdw")
		GaeaValue.Type.RANGE:
			return preload("uid://dy3oumbnydlmp")
		GaeaValue.Type.BITMASK, GaeaValue.Type.BITMASK_EXCLUSIVE, GaeaValue.Type.FLAGS:
			return preload("uid://chdg8ey4ln8d1")
		GaeaValue.Type.CATEGORY:
			return preload("uid://x6n8ylnxoyno")
		GaeaValue.Type.BOOLEAN:
			return preload("uid://byaonbbfa2bx8")
		GaeaValue.Type.VECTOR3:
			return preload("uid://mlwupvg8a886")
		GaeaValue.Type.NEIGHBORS:
			return preload("uid://d11yc7l6sneof")
		GaeaValue.Type.RULES:
			return preload("uid://dy4n2a5hkaxsb")
	return preload("uid://i2nwlab8rau")
