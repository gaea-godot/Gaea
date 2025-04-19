@tool
class_name GaeaNodeSlot extends Resource


#region Inspector related virtual methods
func _update_resource_name() -> void:
	if _property_can_revert(&"resource_name"):
		resource_name = _property_get_revert(&"resource_name")


func _property_can_revert(property: StringName) -> bool:
	match property:
		&"resource_name":
			return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"resource_name":
			var _resource_name = get(&"name").capitalize()
			var type_key = GaeaValue.Type.find_key(get(&"type"))
			if type_key != null:
				type_key = type_key.capitalize()
				if _resource_name != type_key:
					_resource_name += " (%s)" % type_key.capitalize()
			return _resource_name
	return null
#endregion
