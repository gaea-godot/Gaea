@tool
extends GaeaNodeResource
class_name GaeaNodeFalloffMap
## Returns a grid that goes from higher values in the center to lower in the borders.
## Rate can be adjusted with [param start] and [param end].
##
## For lower [param start] values, the transition will be smoother.[br]
## For lower [param end] values, the generated 'square' will be smaller.[br]
## Multiplying this with a [GaeaNodeSimplexSmooth]'s generation can create island-looking terrains.

enum FalloffShape {
	SQUARE,
	ROUNDED_SQUARE,
	CIRCLE,
	SQUIRCLE,
}


@abstract class FalloffSampler:
	var area: AABB
	var start: float
	var end: float
	var pos_x: float
	var pos_y: float
	var size_x: float
	var size_y: float
	var size_x_is_smaller: bool
	var size_y_is_smaller: bool
	var size_x_ajusted: float
	var size_y_ajusted: float
	var size_x_half: float
	var size_y_half: float
	var size_x_minus_y_half: float
	var size_y_minus_x_half: float

	func _init(_area: AABB, _start: float, _end: float):
		area = _area
		start = _start
		end = _end
		pos_x = area.position.x
		pos_y = area.position.y
		size_x = area.size.x
		size_y = area.size.y
		var ratio: float = 1.0
		size_x_is_smaller = size_x <= size_y
		if not size_x_is_smaller:
			ratio = float(size_y) / float(size_x)
		size_y_is_smaller = size_y <= size_x
		if not size_y_is_smaller:
			ratio = float(size_x) / float(size_y)
		size_x_ajusted = size_x * ratio
		size_y_ajusted = size_y * ratio
		size_x_half = size_x * 0.5
		size_y_half = size_y * 0.5
		size_x_minus_y_half = size_x - size_y_half
		size_y_minus_x_half = size_y - size_x_half
		_on_init()

	func _on_init():
		pass

	func normalize_x(x: float) -> float:
		x -= pos_x
		if size_x_is_smaller:
			return remap(x, 0, size_x - 1.0, -1.0, 1.0)
		if x < size_y_half:
			return remap(x, 0, size_x_ajusted - 1.0, -1.0, 1.0)
		if x > size_x_minus_y_half:
			return remap(size_x - x, 1.0, size_x_ajusted, -1.0, 1.0)
		return 0

	func normalize_y(y: float) -> float:
		y -= pos_y
		if size_y_is_smaller:
			return remap(y, 0, size_y - 1.0, -1.0, 1.0)
		if y < size_x_half:
			return remap(y, 0, size_y_ajusted - 1.0, -1.0, 1.0)
		if y > size_y_minus_x_half:
			return remap(size_y - y, 1.0, size_y_ajusted, -1.0, 1.0)
		return 0

	func sample(x: int, y: int) -> float:
		var value: float = clampf(_get_sample(x, y), 0.0, 1.0)

		if value < start:
			return 1.0
		elif value > end:
			return 0.0
		return smoothstep(1.0, 0.0, inverse_lerp(start, end, value))

	@abstract func _get_sample(_x: int, _y: int) -> float


class FalloffSamplerSquare:
	extends FalloffSampler

	func _get_sample(x: int, y: int) -> float:
		return maxf(absf(normalize_x(x)), absf(normalize_y(y)))


class FalloffSamplerRoundedSquare:
	extends FalloffSampler

	func _get_sample(x: int, y: int) -> float:
		return sqrt(normalize_x(x) ** 4 + (normalize_y(y)) ** 4)


class FalloffSamplerCircle:
	extends FalloffSampler
	var one_on_sqrt_two: float

	func _on_init():
		one_on_sqrt_two = 1.0 / sqrt(2.0)

	func _get_sample(x: int, y: int) -> float:
		return min(1.0, (normalize_x(x) ** 2 + normalize_y(y) ** 2) * one_on_sqrt_two)


class FalloffSamplerSquircle:
	extends FalloffSampler

	func _get_sample(x: int, y: int) -> float:
		return 1.0 - (1.0 - normalize_x(x) ** 2) * (1.0 - normalize_y(y) ** 2)


func _get_title() -> String:
	return "FalloffMap"


func _get_description() -> String:
	return "Returns a grid that goes from higher values in the center to lower in the borders.\nRate can be adjusted with [param start] and [param end]."

func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	return FalloffShape


func _get_arguments_list() -> Array[StringName]:
	return [&"start", &"end"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"start":
			return 0.5
		&"end":
			return 1.0
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"data"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var start: float = _get_arg(&"start", area, graph)
	var end: float = _get_arg(&"end", area, graph)
	var grid: Dictionary[Vector3i, float]
	var sampler: FalloffSampler
	match get_enum_selection(0):
		FalloffShape.SQUARE:
			sampler = FalloffSamplerSquare.new(area, start, end)
		FalloffShape.ROUNDED_SQUARE:
			sampler = FalloffSamplerRoundedSquare.new(area, start, end)
		FalloffShape.CIRCLE:
			sampler = FalloffSamplerCircle.new(area, start, end)
		FalloffShape.SQUIRCLE:
			sampler = FalloffSamplerSquircle.new(area, start, end)

	for x in _get_axis_range(Vector3i.AXIS_X, area):
		for y in _get_axis_range(Vector3i.AXIS_Y, area):
			grid[Vector3i(x, y, 0)] = sampler.sample(x, y)
	return grid
