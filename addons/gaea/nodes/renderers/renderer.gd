@tool
@icon("../../assets/renderer.svg")
@abstract
class_name GaeaRenderer
extends Node
## Renders the [member generator]'s result into the game.
##
## This is an abstract class. On its own, it doesn't do anything,
## but it can be extended to customize the way your generation will be rendered.

## Emitted when the node is done with rendering an area.
signal render_finished
## Emitted when [method reset] is called.
signal render_reset
## Emitted when an area of the render has been erased.
signal area_erased(area: AABB)

## Will render this [GaeaGenerator]'s generation results.
@export var generator: GaeaGenerator :
	set(value):
		if is_instance_valid(generator):
			if generator.generation_finished.is_connected(render):
				generator.generation_finished.disconnect(render)
			if generator.area_erased.is_connected(erase_area):
				generator.area_erased.disconnect(erase_area)
			if generator.reset_requested.is_connected(reset):
				generator.reset_requested.disconnect(reset)
		generator = value
		_connect_signals()



func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	if not is_instance_valid(generator):
		return

	if not generator.generation_finished.is_connected(render):
		generator.generation_finished.connect(render)
	if not generator.area_erased.is_connected(erase_area):
		generator.area_erased.connect(erase_area)
	if not generator.reset_requested.is_connected(reset):
		generator.reset_requested.connect(reset)


## Public version of [method _render].
func render(grid: GaeaGrid) -> void:
	_render(grid)
	render_finished.emit()


## Public version of [method _reset].
func reset() -> void:
	_reset()
	render_reset.emit()


## Public version of [method _erase_area].
func erase_area(area: AABB) -> void:
	_erase_area(area)
	area_erased.emit(area)


## Should be overridden with custom behavior for rendering the [param grid].
@abstract
func _render(_grid: GaeaGrid) -> void


## Should be overridden with custom behavior for erasing the rendered [param area].
@abstract
func _erase_area(_area: AABB) -> void


## Should be overridden with custom behavior to clear/reset the previously-rendered generation.
## Should return the render to a 'default' state.
@abstract
func _reset() -> void
