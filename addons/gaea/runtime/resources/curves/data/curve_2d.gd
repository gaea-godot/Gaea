@tool
class_name GaeaCurve2D
extends GaeaCurve
## A [GaeaCurve] wrapper for Godot's builtin [Curve2D] class.

enum AggregationMethod
{
	## Use just the X value.
	X,
	## Use just the Y value.
	Y,
	## Use the average of the X and Y values.
	AVERAGE,
}

## The [Curve2D] to use for sampling.
@export var curve: Curve2D

@export_category("Conversion to 1D Sample")
## The [enum AggregationMethod] to use when populating [method GaeaCurve.sample] results.
@export var x_aggregation_1D: AggregationMethod = AggregationMethod.X
## Default value when populating [method sample_3d] results.
@export var z_default_3D: float = 0


func _sample(offset: float) -> float:
	var result = curve.sample(0, offset)
	match x_aggregation_1D:
		AggregationMethod.X: return result.x
		AggregationMethod.Y: return result.y
		AggregationMethod.AVERAGE, _: return (result.x + result.y) * 0.5


func _sample_2d(idx: int, t: float) -> Vector2:
	return curve.sample(idx, t)


func _sample_3d(idx: int, t: float) -> Vector3:
	var result = curve.sample(idx, t)
	return Vector3(result.x, result.y, z_default_3D)
