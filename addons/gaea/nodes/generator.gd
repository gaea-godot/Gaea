@tool
@icon("../assets/generator.svg")
class_name GaeaGenerator
extends Node
## Generates a grid of [GaeaMaterial]s using the graph at [member data] to be rendered by a
## [GaeaRendered] or used in other ways.


## Emitted when [GaeaGraph] is changed.
signal data_changed
@warning_ignore("unused_signal")
## Emitted when the graph is done with the generation.
signal generation_finished(grid: GaeaGrid)
## Emitted when this generator wants to trigger a reset. See [method GaeaRenderer._reset].
signal reset_requested
## Emitted when an [param area] is erased.
signal area_erased(area: AABB)


## The [GaeaGraph] used for generation.
@export var data: GaeaGraph:
	set(value):
		data = value
		if is_instance_valid(data):
			data.generator = self
		data_changed.emit()
## The seed used for the randomization of the generation.
@warning_ignore("shadowed_global_identifier")
@export var seed: int = randi()
## If [code]true[/code], every time [method generate] is called, a random [member seed] will be chosen.
@export var random_seed_on_generate: bool = true
## Leave [param z] as [code]1[/code] for 2D worlds.
@export var world_size: Vector3i = Vector3i(128, 128, 1)
## Used with [ChunkLoader]s, or to get the cell position of a node with [method global_to_map].
## Not necessary for generation to work.
@export var cell_size: Vector3i = Vector3i(16, 16, 1)


## Start the generaton process. First resets the current generation, then generates the whole
## [member world_size].
func generate() -> void:
	if random_seed_on_generate:
		seed = randi()
	request_reset()
	generate_area(AABB(Vector3.ZERO, world_size))


## Generate an [param area] using the graph saved in [member data].
func generate_area(area: AABB) -> void:
	data.generator = self
	var connections: Array[Dictionary] = data.get_all_connections()
	var output_resource: GaeaNodeOutput

	for resource in data.get_nodes():
		resource.connections.clear()
		if resource is GaeaNodeOutput:
			output_resource = resource

	for idx in connections.size():
		var connection: Dictionary = connections[idx]
		var resource: GaeaNodeResource = data.get_node(connection.to_node)
		resource.connections.append(connection)

	output_resource.execute(
		area,
		data,
		self
	)

	data.cache.clear()


## Emits [signal area_erased]. Does nothing by itself, but notifies [GaeaRenderer]s that they should
## erase the points of [param area].
func request_area_erasure(area: AABB) -> void:
	area_erased.emit.call_deferred(area)


## Returns [param position] in cell coordinates based on [member cell_size].
func global_to_map(position: Vector3) -> Vector3i:
	return (position / Vector3(cell_size)).floor()


## Emits [signal reset_requested]. Does nothing by itself, but notifies [GaeaRenderer]s that they should
## reset the current generation.
func request_reset() -> void:
	reset_requested.emit()
