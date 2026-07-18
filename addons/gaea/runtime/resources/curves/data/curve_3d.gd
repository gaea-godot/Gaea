@tool
class_name GaeaCurve3D
extends GaeaCurve
## A [GaeaCurve] wrapper for Godot's builtin [Curve3D] class.

enum AggregationMethod
{
	## Use just the X value.
	X,
	## Use just the Y value.
	Y,
	## Use just the Z value.
	Z,
	## When [method GaeaCurve.sample] is called, [member scalar_aggregation] indicates using the
	## average of the X, Y and Z values.[br][br]
	## When [method GaeaCurve.sample_2d] is called, [member x_aggregation] indicates using the average
	## of the X and Z values to populate the x component, and [member y_aggregation] indicates using
	## the average of the Y and Z values.
	AVERAGE,
}

## The [Curve3D] to use for sampling.
@export var curve: Curve3D

@export_category("Conversion to 2D and 1D Sample")
## The [enum AggregationMethod] to use when populating [method GaeaCurve.sample] results.
@export var x_aggregation_1D: AggregationMethod = AggregationMethod.X
## The [enum AggregationMethod] to use when populating the x value of [method GaeaCurve.sample_2d] results.
@export var x_aggregation_2D: AggregationMethod = AggregationMethod.X
## The [enum AggregationMethod] to use when populating the y value of [method GaeaCurve.sample_2d] results.
@export var y_aggregation_2D: AggregationMethod = AggregationMethod.Y


func _sample(offset: float) -> float:
	var result = curve.sample(0, offset)
	return _aggregate_scalar(result, x_aggregation_1D)


func _sample_2d(idx: int, t: float) -> Vector2:
	var result = curve.sample(idx, t)
	return _aggregate_vector2(result, x_aggregation_2D, y_aggregation_2D)


func _sample_3d(idx: int, t: float) -> Vector3:
	return curve.sample(idx, t)


func _aggregate_scalar(vector: Vector3, method: AggregationMethod):
	match method:
		AggregationMethod.X: return vector.x
		AggregationMethod.Y: return vector.y
		AggregationMethod.Z: return vector.z
		AggregationMethod.AVERAGE, _: return (vector.x + vector.y + vector.z)/3


func _aggregate_vector2(vector: Vector3, x_method: AggregationMethod, y_method: AggregationMethod) -> Vector2:
	var x: float = 0
	match x_method:
		AggregationMethod.X: x = vector.x
		AggregationMethod.Y: x = vector.y
		AggregationMethod.Z: x = vector.z
		AggregationMethod.AVERAGE: x = (vector.x + vector.z)/2

	var y: float = 0
	match y_method:
		AggregationMethod.X: y = vector.x
		AggregationMethod.Y: y = vector.y
		AggregationMethod.Z: y = vector.z
		AggregationMethod.AVERAGE: y = (vector.y + vector.z)/2

	return Vector2(x, y)
