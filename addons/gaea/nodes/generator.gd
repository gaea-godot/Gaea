@tool
@icon("../assets/generator.svg")
class_name GaeaGenerator
extends Node
## Generates a grid of [GaeaMaterial]s using the graph at [member graph] to be rendered by a
## [GaeaRendered] or used in other ways.


## Emitted when [GaeaGraph] is changed.
signal graph_changed(old_graph: GaeaGraph)
## Emitted when the graph is about to generate.
signal about_to_generate
## Emitted when a [GaeaGenerationTask] is queued.
signal generation_started()
## Emitted when a [GaeaGenerationTask] is canceled.
signal generation_cancelled()
## Emitted a [GaeaGenerationTask] has finished.
signal generation_finished(grid: GaeaGrid)
## Emitted when this generator wants to trigger a reset. See [method GaeaRenderer._reset].
signal reset_requested
## Emitted when an [param area] is erased.
signal area_erased(area: AABB)


## The [GaeaGraph] used for generation.
@export var graph: GaeaGraph:
	set(value):
		var old_graph: GaeaGraph = graph
		graph = value
		if is_instance_valid(graph):
			graph.ensure_initialized()
		graph_changed.emit(old_graph)

@export var settings: GaeaGenerationSettings


## The thread pool used by the Generator to perform tasks on multiple threads,
## with the help of the built-in [WorkerThreadPool].
@export var task_pool: GaeaTaskPool :
	get:
		if not task_pool:
			task_pool = GaeaTaskPool.new()
		if not task_pool.task_finished.is_connected(_execution_task_finished):
			task_pool.task_finished.connect(_execution_task_finished)
		if not task_pool.task_started.is_connected(generation_started.emit.unbind(1)):
			task_pool.task_started.connect(generation_started.emit.unbind(1))
		if not task_pool.task_discarded.is_connected(generation_cancelled.emit.unbind(1)):
			task_pool.task_discarded.connect(generation_cancelled.emit.unbind(1))
		if not task_pool.task_discarded.is_connected(generation_cancelled.emit.unbind(1)):
			task_pool.task_cancelled.connect(generation_cancelled.emit.unbind(1))
		return task_pool


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


## Start the generaton process. First resets the current generation,
## then generates the whole [member world_size].
## [br] See [member GaeaGenerationPriority._origin] for [member origin] type.
func generate(origin: Variant = null) -> GaeaTask:
	about_to_generate.emit()
	if settings.random_seed_on_generate:
		settings.seed = randi()
	request_reset()
	return generate_area(AABB(Vector3.ZERO, settings.world_size), origin)


## Generate an [param area] using the graph saved in [member graph].
## [br] See [member GaeaGenerationPriority._origin] for [member origin] type.
func generate_area(area: AABB, origin: Variant = null) -> GaeaTask:
	var pouch: GaeaGenerationPouch = GaeaGenerationPouch.new(settings, area)

	var task := GaeaGenerationTask.new(
		"Execute on %s" % area.position,
		graph,
		pouch
	)
	if is_instance_valid(origin):
		task.set_priority_origin(origin)

	task_pool.submit(task)
	return task


func cancel_generation():
	task_pool.cancel_all()
	generation_cancelled.emit()


## Emits [signal generation_finished] on the given results of the given [GaeaGenerationTask]
func _execution_task_finished(task: GaeaTask):
	var exec: GaeaGenerationTask = task as GaeaGenerationTask
	graph.log_lazy(GaeaGraph.Log.THREADING, func():
		return "Finishing execution, result has %d elements." % exec.results.get_grid_data().size()
	)
	generation_finished.emit.call_deferred(exec.results)
	exec.pouch.clear_all_cache()


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
