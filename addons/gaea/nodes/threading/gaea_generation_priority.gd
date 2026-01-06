@tool
class_name GaeaGenerationPriority
extends GaeaPriority
## Calculates priority [member level] based on distance of
## [member area] from [member origin].
##
## Treats the distance between [member area]'s position
## and the [member origin] position as a priority axis. The closer the given area is
## to the player for example, the higher its priority.
## [br][br]
## [member origin] is not limited to simple vector positions.
## [br][br]
## Useful for chunk generation.


## Origin can have a number of different types, all of which will be
## silently converted to a Vector4 (used for maximum compatibility).
## [br][br]
## Some types are specifically handled:
## [br][br]
## 1. Vector types
## [br][br]
## [center]i.e. [Vector2] (3, 4) converted component-wise to [Vector4] (3, 4, 0, 0)[/center]
## [br][br]
## 2. [Node2D], [Node3D], [Control]
## [br][br]
## [center]i.e. [member Node2D.global_position] converted component-wise[/center]
## [br][br]
## 3. [Callable]
## [br]
## [center]return value converted as above[/center]
## [br][br]
## All unhandled types default to [constant Vector4.ZERO]:
var _origin: Variant

## The area to measure distance off of.
## [br][br]
## The position is calculated using:
## [br][br]
## [center][member AABB.position] / [member AABB.size][/center]
var _area: AABB


func _init(origin: Variant, area: AABB) -> void:
	_origin = origin
	_area = area


func set_source_origin(origin: Variant) -> void:
	_origin = origin


func get_source_origin() -> Variant:
	return _origin


func _get_origin() -> Vector4:
	var value = _origin
	if _origin is Callable:
		value = _origin.call()
	if value is Node:
		if value is Node2D or value is Node3D or value is Control:
			return Vector.to_vec4(value.global_position)
		return Vector4.ZERO
	return Vector.to_vec4(value)


func _calculate() -> float:
	var position := Vector.to_vec4(_area.position / _area.size)
	return _get_origin().distance_squared_to(position)


## A tool for converting any vector into a [Vector4].
class Vector:
	const HAS_VALID_W: Array[Variant.Type] = [TYPE_VECTOR4, TYPE_VECTOR4I]
	const HAS_VALID_Z: Array[Variant.Type] = [TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
	const HAS_VALID_Y: Array[Variant.Type] = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
	const HAS_VALID_X: Array[Variant.Type] = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

	## Converts vectors into [Vector4]s.
	static func to_vec4(vector: Variant) -> Vector4:
		var v_type := typeof(vector)
		var x := 0.0
		if v_type in HAS_VALID_X:
			x = vector.x
		var y := 0.0
		if v_type in HAS_VALID_Y:
			y = vector.y
		var z := 0.0
		if v_type in HAS_VALID_Z:
			z = vector.z
		var w := 0.0
		if v_type in HAS_VALID_W:
			w = vector.w
		return Vector4(x, y, z, w)
