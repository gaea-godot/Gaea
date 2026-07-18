@tool
@icon("Curve")
@abstract
class_name GaeaCurve
extends Resource
## A base class used to enable use of [Curve] classes within the [GaeaGraph].
##
## This is an abstract class. On its own, it doesn't do anything aside from return 0 values.
## It is meant to be extended for the sake of acting as a wrapper for various [Curve]-like classes.
## See [GaeaCurveScalar], [GaeaCurve2D], and [GaeaCurve3D].


## Public version of [method _sample]. Prefer overriding that method instead of this one.
func sample(offset:float) -> float:
	return _sample(offset)

## Samples a curve and returns a one-dimensional, scalar result.
func _sample(_offset:float) -> float:
	return 0


## Public version of [method _sample_2d]. Prefer overriding that method instead of this one.
func sample_2d(idx: int, t: float) -> Vector2:
	return _sample_2d(idx, t)

## Samples a curve and returns a two-dimensional, vector result.
func _sample_2d(_idx: int, _t: float) -> Vector2:
	return Vector2.ZERO


## Public version of [method _sample_3d]. Prefer overriding that method instead of this one.
func sample_3d(idx: int, t: float) -> Vector3:
	return _sample_3d(idx, t)

## Samples a curve and returns a three-dimensional, vector result.
func _sample_3d(_idx: int, _t: float) -> Vector3:
	return Vector3.ZERO
