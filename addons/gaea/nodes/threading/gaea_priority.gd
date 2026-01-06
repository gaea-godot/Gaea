@tool
@icon("../../assets/slots/triangle.svg")
class_name GaeaPriority
extends RefCounted
## Used for on-demand priority calculations.
##
## As a base class, simply allows a simple priority [member level] to be set
## for use in the [GaeaTask]s and the [GaeaTaskPool].
## [br][br]
## As an example of why this is useful, the priority [member level] could
## be set by a controlling class after a [GaeaTask] is already submitted to
## a [GaeaTaskPool], allowing the [GaeaTaskPool] to dynamically sort
## the order of its [GaeaTask] queue.
## [br][br]
## What any priority [member level] means relative to another is
## fundamentally arbitrary.


## An arbitrary priority level.
var level: float:
	get = _calculate


@warning_ignore("shadowed_variable")
func _init(level: float) -> void:
	self.level = level


func _set_value(value) -> void:
	level = value


func _calculate() -> float:
	return level
