@tool
class_name GaeaNodeFalloffMap
extends GaeaNodeResource
## Returns a grid that goes from higher values in the center to lower in the borders.
## Rate can be adjusted with [param start] and [param end].
##
## For lower [param start] values, the transition will be smoother.[br]
## For lower [param end] values, the generated 'square' will be smaller.[br]
## Multiplying this with a [GaeaNodeSimplexSmooth]'s generation can create island-looking terrains.

## Area preset choices.
enum FalloffArea {
	## The area encompassed by a given generation task. Often means the space a given chunk takes up.
	CHUNK_AREA,
	## The world area defined in the generation settings.
	WORLD_AREA,
	## A custom area defined by position and size arguments.
	CUSTOM_AREA,
}

## Shapes calculated off of normalized position vectors relative to [member FalloffSampler.area]
enum FalloffShape {
	## Based on a [code] max(x, y, z) [/code] algorithm.
	SQUARE,
	## Based on a [code] sqrt(x^4 + y^4 + z^4) [/code] algorithm.
	ROUNDED_SQUARE,
	## Based on a [code] min(1, vector.length) [/code] algorithm.
	CIRCLE,
	## Based on a [code] 1 - (1-x^2) (1-y^2) (1-z^2) [/code]
	SQUIRCLE,
}

@abstract
class FalloffSampler:
	var area: AABB
	var curve: GaeaCurve
	var start: float
	var end: float
	var pos: Vector3
	var center: Vector3
	var radii: Vector3

	func _init(_area: AABB, _curve: GaeaCurve, _start: float, _end: float):
		area = _area
		curve = _curve
		start = _start
		end = _end
		pos = area.position
		center = area.get_center()
		radii = area.size * 0.5
		_on_init()

	func _on_init():
		pass

	func normalize(vector:Vector3) -> Vector3:
		# vector relative to the center, normalized based on radii
		return (vector - center) / radii

	func sample(vector: Vector3) -> float:
		var value: float = clampf(_get_sample(vector), 0.0, 1.0)
		var range_clamped: float = clampf(value, start if start < end else end, end if end > start else start)

		var offset: float
		match range_clamped:
			start: offset = 1.0
			end: offset = 0.0
			_: offset = smoothstep(1.0, 0.0, inverse_lerp(start, end, value))

		return offset if not curve else curve.sample(offset)

	@abstract
	func _get_sample(_vector:Vector3) -> float


class FalloffSamplerSquare:
	extends FalloffSampler

	func _get_sample(vector:Vector3) -> float:
		var absolute_normal := normalize(vector).abs()
		return maxf(maxf(absolute_normal.x, absolute_normal.y), absolute_normal.z)


class FalloffSamplerRoundedSquare:
	extends FalloffSampler

	func _get_sample(vector:Vector3) -> float:
		var normalized := normalize(vector)
		return sqrt(normalized.x ** 4 + normalized.y ** 4 + normalized.z ** 4)


class FalloffSamplerCircle:
	extends FalloffSampler
	var one_on_sqrt_two: float

	func _on_init():
		one_on_sqrt_two = 1.0 / sqrt(2.0)

	func _get_sample(vector: Vector3) -> float:
		return min(1.0, normalize(vector).length())


class FalloffSamplerSquircle:
	extends FalloffSampler

	func _get_sample(vector: Vector3) -> float:
		var normalized = normalize(vector)
		return 1.0 - ((1.0 - (normalized.x ** 2)) * (1.0 - (normalized.y ** 2)) * (1.0 - (normalized.z ** 2)))


func _get_title() -> String:
	return "FalloffMap"


func _get_description() -> String:
	return """Returns a grid that goes from higher values in the center to lower in the borders.
Rate can be adjusted with [param start] and [param end]."""


func _get_enums_count() -> int:
	return 2


func _get_enum_options(idx: int) -> Dictionary:
	match idx:
		0: return FalloffArea
		1, _: return FalloffShape


func _on_enum_value_changed(enum_idx: int, _option_value: int) -> void:
	match enum_idx:
		0: notify_argument_list_changed()


func _get_arguments_list() -> Array[StringName]:
	var list: Array[StringName]
	match get_enum_selection(0): # Faloff Area
		FalloffArea.CUSTOM_AREA:
			list = [&"position", &"size"]
		_:
			list = []
	list.append_array([&"curve", &"restrict_x", &"restrict_y", &"restrict_z", &"start", &"end"])
	return list


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"position", &"size": return GaeaValue.Type.VECTOR3
		&"curve": return GaeaValue.Type.CURVE
		&"restrict_x": return GaeaValue.Type.BOOLEAN
		&"restrict_y": return GaeaValue.Type.BOOLEAN
		&"restrict_z": return GaeaValue.Type.BOOLEAN
		&"start", &"end", _: return GaeaValue.Type.FLOAT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"position": return Vector3.ZERO
		&"area": return Vector3.ONE
		&"curve": return null
		&"restrict_x": return false
		&"restrict_y": return false
		&"restrict_z": return false
		&"start": return 0.5
		&"end": return 1.0
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"falloff"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_data(_output_port: StringName, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	var start: float = _get_arg(&"start", pouch) as float
	var end: float = _get_arg(&"end", pouch) as float
	var curve: GaeaCurve = _get_arg(&"curve", pouch) as GaeaCurve
	var restrict_x: bool = _get_arg(&"restrict_x", pouch) as bool
	var restrict_y: bool = _get_arg(&"restrict_y", pouch) as bool
	var restrict_z: bool = _get_arg(&"restrict_z", pouch) as bool
	var result: GaeaValue.Sample = GaeaValue.Sample.new()

	var area: AABB
	match get_enum_selection(0): # Falloff Area
		FalloffArea.CHUNK_AREA:
			area = pouch.area
		FalloffArea.WORLD_AREA:
			area = AABB(Vector3.ZERO, pouch.settings.world_size)
		FalloffArea.CUSTOM_AREA:
			var position: Vector3 = _get_arg(&"position", pouch)
			var size: Vector3 = _get_arg(&"size", pouch)
			area = AABB(position, size)


	var sampler: FalloffSampler
	match get_enum_selection(1): # Falloff Shape
		FalloffShape.SQUARE:
			sampler = FalloffSamplerSquare.new(area, curve, start, end)
		FalloffShape.ROUNDED_SQUARE:
			sampler = FalloffSamplerRoundedSquare.new(area, curve, start, end)
		FalloffShape.CIRCLE:
			sampler = FalloffSamplerCircle.new(area, curve, start, end)
		FalloffShape.SQUIRCLE:
			sampler = FalloffSamplerSquircle.new(area, curve, start, end)

	for x in _get_axis_range(Vector3i.AXIS_X, area):
		for y in _get_axis_range(Vector3i.AXIS_Y, area):
			for z in _get_axis_range(Vector3i.AXIS_Z, area):
				var sample_vector: Vector3i = Vector3i.ZERO
				sample_vector.x = sampler.center.x if restrict_x else x
				sample_vector.y = sampler.center.y if restrict_y else y
				sample_vector.z = sampler.center.z if restrict_z else z
				result.set_xyz(x, y, z, sampler.sample(sample_vector))
	return result
