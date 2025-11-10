@tool
@icon("../assets/generator.svg")
class_name GaeaGenerator
extends Node
## Generates a grid of [GaeaMaterial]s using the graph at [member graph] to be rendered by a
## [GaeaRendered] or used in other ways.


## Emitted when [GaeaGraph] is changed.
signal graph_changed
## Emitted when the graph is about to generate.
signal about_to_generate
## Emitted when the graph is done with the generation.
@warning_ignore("unused_signal")
signal generation_finished(grid: GaeaGrid)
## Emitted when this generator wants to trigger a reset. See [method GaeaRenderer._reset].
signal reset_requested
## Emitted when an [param area] is erased.
signal area_erased(area: AABB)



@warning_ignore("unused_private_class_variable")
@export_tool_button("Generate", "Play") var _button_generate = generate
@warning_ignore("unused_private_class_variable")
@export_tool_button("Clear", "Remove") var _button_clear = request_reset


## The [GaeaGraph] used for generation.
@export var graph: GaeaGraph:
	set(value):
		graph = value
		graph._setup_local_to_scene()
		graph_changed.emit()

@export var settings: GaeaGenerationSettings

# For migration to GaeaGenerationSettings
func _set(property: StringName, value: Variant) -> bool:
	match property:
		&"data":
			graph = value
			return true
		&"random_seed_on_generate", &"seed", &"world_size", &"cell_size":
			_migrate_settings_property(property, value)
			return true
	return false


func _migrate_settings_property(property: StringName, value: Variant):
	if settings == null:
		settings = GaeaGenerationSettings.new()
	settings.set(property, value)


## Start the generaton process. First resets the current generation, then generates the whole
## [member world_size].
func generate() -> void:
	about_to_generate.emit()
	if settings.random_seed_on_generate:
		settings.seed = randi()
	request_reset()
	generate_area(AABB(Vector3.ZERO, settings.world_size))


## Generate an [param area] using the graph saved in [member graph].
func generate_area(area: AABB) -> void:
	var connections: Array[Dictionary] = graph.get_all_connections()
	var output_resource: GaeaNodeOutput

	for resource in graph.get_nodes():
		resource.connections.clear()
		if resource is GaeaNodeOutput:
			output_resource = resource

	for idx in connections.size():
		var connection: Dictionary = connections[idx]
		var resource: GaeaNodeResource = graph.get_node(connection.to_node)
		resource.connections.append(connection)

	var generation_settings = settings.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	generation_settings.area = area
	generation_finished.emit.call_deferred(output_resource.execute(graph, generation_settings))

	graph.cache.clear()


## Emits [signal area_erased]. Does nothing by itself, but notifies [GaeaRenderer]s that they should
## erase the points of [param area].
func request_area_erasure(area: AABB) -> void:
	area_erased.emit.call_deferred(area)


## Returns [param position] in cell coordinates based on [member cell_size].
func global_to_map(position: Vector3) -> Vector3i:
	return (position / Vector3(settings.cell_size)).floor()


## Emits [signal reset_requested]. Does nothing by itself, but notifies [GaeaRenderer]s that they should
## reset the current generation.
func request_reset() -> void:
	reset_requested.emit()
