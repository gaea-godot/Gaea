@tool
@icon("../../assets/types/material.svg")
@abstract
class_name GaeaMaterial
extends Resource
## Used to tell the [GaeaRenderer] what to draw at a specific point.
## The result of a Gaea generation is a grid of this resource.
##
## This is an abstract class. On its own, it doesn't do anything,
## but it can be extended to hold data related to the chosen rendering method.
## See [TileMapMaterial] and [GridMapMaterial].
## It can also be used to hold sub-resources to be selected programmatically. See [PointwiseRandomGaeaMaterial].

const RECURSIVE_LIMIT = 10

@export_group("Preview", "preview_")
## Color used for previews in the graph interface or in the [GradientGaeaMaterial] inspector.
@export var preview_color: Color = Color.TRANSPARENT


func _init() -> void:
	if preview_color == Color.TRANSPARENT:
		preview_color = Color(randf(), randf(), randf())


## Public version of [method _is_sampled]. Prefer overriding that method instead of this one.
func is_sampled() -> bool:
	return _is_sampled()


## Whether or not this material is sampled for each cell.
@abstract
func _is_sampled() -> bool


## Public version of [method _is_data]. Prefer overriding that method instead of this one.
func is_data() -> bool:
	return _is_data()


## Whether or not this material is a valid data material for the renderer.
@abstract
func _is_data() -> bool


## Public version of [method _get_sampled_resource]. Prefer overriding that method instead of this one.
func get_sampled_resource(rng: RandomNumberGenerator, value: float) -> GaeaMaterial:
	return _get_sampled_resource(rng, value)


## Normally returns itself, but can be overridden to return other [GaeaMaterial] resources
## depending on specific behavior. Called for each point by the mapper.
## Used only when [method _is_sampled] returns [code]true[/code].
func _get_sampled_resource(_rng: RandomNumberGenerator, _value: float) -> GaeaMaterial:
	return self


## Public version of [method _get_resource]. Prefer overriding that method instead of this one.
func get_resource(rng: RandomNumberGenerator) -> GaeaMaterial:
	return _get_resource(rng)


## Normally returns itself, but can be overridden to return other [GaeaMaterial] resources
## depending on specific behavior. Called once by the mapper.
## Used only when [method _is_sampled] returns [code]false[/code].
func _get_resource(_rng: RandomNumberGenerator) -> GaeaMaterial:
	return self


## Process the recurse looping of the material until a material is sampled
func prepare_sample(rng: RandomNumberGenerator) -> GaeaMaterial:
	var loop_limit = RECURSIVE_LIMIT
	var material = self
	while loop_limit > 0 and not material.is_data() and not material.is_sampled():
		loop_limit -= 1
		material = material.get_resource(rng)
	if loop_limit == 0:
		return null
	return material


## Process the recurse looping of the material until the end.
func execute_sample(rng: RandomNumberGenerator, value: float) -> GaeaMaterial:
	var material = self
	var loop_limit = RECURSIVE_LIMIT
	while loop_limit > 0:
		loop_limit -= 1
		if material.is_data():
			return material
		if material.is_sampled():
			material = material.get_sampled_resource(rng, value)
		else:
			material = material.get_resource(rng)
	return null
