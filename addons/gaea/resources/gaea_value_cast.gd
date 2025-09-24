@tool
class_name GaeaValueCast
extends RefCounted

## List of casting methods, the first Dictionary key is "from type" and the second is "to type"
## and the value is the transform [Callable].
static var _casts_methods: Dictionary[GaeaValue.Type, Dictionary] = {
	GaeaValue.Type.BOOLEAN: {
		GaeaValue.Type.INT:      func(value: bool): return int(value),
		GaeaValue.Type.FLOAT:    func(value: bool): return float(value),
		GaeaValue.Type.VECTOR2:  func(value: bool): return Vector2(float(value), float(value)),
		GaeaValue.Type.VECTOR2I: func(value: bool): return Vector2i(int(value), int(value)),
		GaeaValue.Type.VECTOR3:  func(value: bool): return Vector3(float(value), float(value), float(value)),
		GaeaValue.Type.VECTOR3I: func(value: bool): return Vector3i(int(value), int(value), int(value)),
		GaeaValue.Type.RANGE:    func(value: bool): return {"min": float(value), "max": float(value)},
	},
	GaeaValue.Type.FLOAT: {
		GaeaValue.Type.BOOLEAN:  func(value: float): return not is_zero_approx(value),
		GaeaValue.Type.INT:      func(value: float): return roundi(value),
		GaeaValue.Type.VECTOR2:  func(value: float): return Vector2(value, value),
		GaeaValue.Type.VECTOR2I: func(value: float): return Vector2i(roundi(value), roundi(value)),
		GaeaValue.Type.VECTOR3:  func(value: float): return Vector3(value, value, value),
		GaeaValue.Type.VECTOR3I: func(value: float): return Vector3i(roundi(value), roundi(value), roundi(value)),
		GaeaValue.Type.RANGE:    func(value: float): return {"min": value, "max": value},
	},
	GaeaValue.Type.INT: {
		GaeaValue.Type.BOOLEAN:  func(value: int): return bool(value),
		GaeaValue.Type.FLOAT:    func(value: int): return float(value),
		GaeaValue.Type.VECTOR2:  func(value: int): return Vector2(float(value), float(value)),
		GaeaValue.Type.VECTOR2I: func(value: int): return Vector2i(value, value),
		GaeaValue.Type.VECTOR3:  func(value: int): return Vector3(float(value), float(value), float(value)),
		GaeaValue.Type.VECTOR3I: func(value: int): return Vector3i(value, value, value),
		GaeaValue.Type.RANGE:    func(value: int): return {"min": float(value), "max": float(value)},
	},
	GaeaValue.Type.VECTOR2: {
		GaeaValue.Type.VECTOR2I: func(value: Vector2): return Vector2i(value.round()),
		GaeaValue.Type.VECTOR3:  func(value: Vector2): return Vector3(value.x, value.y, 0.0),
		GaeaValue.Type.VECTOR3I: func(value: Vector2): return Vector3i(roundi(value.x), roundi(value.y), 0),
		GaeaValue.Type.RANGE:    func(value: Vector2): return {"min": value.x, "max": value.y},
	},
	GaeaValue.Type.VECTOR2I: {
		GaeaValue.Type.VECTOR2:  func(value: Vector2i): return Vector2(value),
		GaeaValue.Type.VECTOR3:  func(value: Vector2i): return Vector3(float(value.x), float(value.y), 0.0),
		GaeaValue.Type.VECTOR3I: func(value: Vector2i): return Vector3i(value.x, value.y, 0),
		GaeaValue.Type.RANGE:    func(value: Vector2i): return {"min": float(value.x), "max": float(value.y)},
	},
	GaeaValue.Type.VECTOR3: {
		GaeaValue.Type.VECTOR2:  func(value: Vector3): return Vector2(value.x, value.y),
		GaeaValue.Type.VECTOR2I: func(value: Vector3): return Vector2i(roundi(value.x), roundi(value.y)),
		GaeaValue.Type.VECTOR3I: func(value: Vector3): return Vector3i(value.round()),
		GaeaValue.Type.RANGE:    func(value: Vector3): return {"min": value.x, "max": value.y},
	},
	GaeaValue.Type.VECTOR3I: {
		GaeaValue.Type.VECTOR2:  func(value: Vector3i): return Vector2(float(value.x), float(value.y)),
		GaeaValue.Type.VECTOR2I: func(value: Vector3i): return Vector2i(value.x, value.y),
		GaeaValue.Type.VECTOR3:  func(value: Vector3i): return Vector3(float(value.x), float(value.y), float(value.z)),
		GaeaValue.Type.RANGE:    func(value: Vector3i): return {"min": float(value.x), "max": float(value.y)},
	},
	GaeaValue.Type.RANGE: {
		GaeaValue.Type.VECTOR2:  func(value: Dictionary): return Vector2(value.get("min"), value.get("max")),
		GaeaValue.Type.VECTOR2I: func(value: Dictionary): return Vector2i(roundi(value.get("min")), roundi(value.get("max"))),
		GaeaValue.Type.VECTOR3:  func(value: Dictionary): return Vector3(value.get("min"), value.get("max"), 0.0),
		GaeaValue.Type.VECTOR3I: func(value: Dictionary): return Vector3i(roundi(value.get("min")), roundi(value.get("max")), 0),
	},
} :
	get = get_cast_methods


## Return the castable types, the inner array is a tuple with [code][from, to][/code]. Both of type [enum GaeaValue.Type].
static func get_cast_list() -> Array[Array]:
	var casts: Array[Array] = []
	for from in _casts_methods.keys():
		for to in _casts_methods.get(from).keys():
			casts.append([from, to])
	return casts


## Returns [member _casts_methods].
static func get_cast_methods() -> Dictionary[GaeaValue.Type, Dictionary]:
	return _casts_methods


## Transforms [param value] from [param from_type] to [param to_type]. If there's no way to do so,
## produces an error.
static func cast_value(from_type: GaeaValue.Type, to_type: GaeaValue.Type, value: Variant) -> Variant:
	if from_type == to_type:
		return value

	var cast_method = _casts_methods.get(from_type, {}).get(to_type, null)
	if cast_method is Callable:
		return cast_method.call(value)

	printerr("Could not get data from previous node, missing cast method from %s to %s" % [
		GaeaValue.Type.find_key(from_type),
		GaeaValue.Type.find_key(to_type),
	])
	return {}
