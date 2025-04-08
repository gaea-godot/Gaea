@tool
@icon("../assets/generator.svg")
class_name GaeaGenerator
extends Node


signal data_changed
@warning_ignore("unused_signal")
signal generation_finished(grid: GaeaGrid)
signal reset_requested
signal area_erased(area: AABB)


@export var data: GaeaData:
	set(value):
		data = value
		if is_instance_valid(data):
			data.generator = self
		data_changed.emit()
@warning_ignore("shadowed_global_identifier")
@export var seed: int = randi()
@export var random_seed_on_generate: bool = true
## Leave [param z] as [code]1[/code] for 2D worlds.
@export var world_size: Vector3i = Vector3i(128, 128, 1)
## Used with [ChunkLoader]s, or to get the cell position of a node with [method global_to_map].
## Not necessary for generation to work.
@export var cell_size: Vector3i = Vector3i(16, 16, 1)
@export var generate_on_ready: bool = true


func _ready() -> void:
	if not Engine.is_editor_hint() and generate_on_ready:
		generate()


func generate() -> void:
	if random_seed_on_generate:
		seed = randi()
	reset()
	generate_area(AABB(Vector3.ZERO, world_size))


func generate_area(area: AABB) -> void:
	data.generator = self
	var connections: Array[Dictionary] = data.connections
	var output_resource: GaeaNodeResource

	for resource in data.resources:
		resource.connections.clear()

	for idx in connections.size():
		var connection: Dictionary = connections[idx]
		var resource: GaeaNodeResource = data.resources[connection.to_node]
		resource.connections.append(connection)

		if resource.is_output:
			output_resource = resource
	
	output_resource.execute(
		area,
		data,
		self
	)
	
	data.cache.clear()


func erase_area(area: AABB) -> void:
	area_erased.emit.call_deferred(area)


func global_to_map(position: Vector3) -> Vector3i:
	return (position / Vector3(cell_size)).floor()


func reset() -> void:
	reset_requested.emit()
