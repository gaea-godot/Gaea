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
## Emitted when all [GaeaGenerationTask]s are canceled.
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

@export_group("Multi-Threading")
## Whether this generator should block the main thread.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "feature") var multithreaded: bool = true

## The max number of this generator's [GaeaGenerationTask]s that can running in the [WorkerThreadPool] at once.
## All extra tasks will be queued to start as soon as room becomes available.
## A value of [code]0[/code] means there will be no queue, and all tasks will be sent to the [WorkerThreadPool] immediately.
@export_range(0, 50, 1) var task_limit: int = 0 :
	set(value):
		task_limit = value
		if is_instance_valid(_task_pool):
			_task_pool.task_limit = value


## The thread pool used by the Generator to perform tasks on multiple threads,
## with the help of the built-in [WorkerThreadPool].
@onready var _task_pool: GaeaTaskPool


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
func generate() -> void:
	about_to_generate.emit()
	if settings.random_seed_on_generate:
		settings.seed = randi()
	request_reset()
	generate_area(AABB(Vector3.ZERO, settings.world_size))


## Generate an [param area] using the graph saved in [member graph].
func generate_area(area: AABB) -> void:
	var pouch: GaeaGenerationPouch = GaeaGenerationPouch.new(settings, area)

	if not multithreaded:
		generation_finished.emit.call_deferred(graph.get_output_node().execute(graph, pouch))
		pouch.clear_all_cache()
		return

	if not _task_pool:
		_task_pool = GaeaTaskPool.new(_execution_task_finished, task_limit)

	var task := GaeaGenerationTask.new(
		"Execute on %s" % area,
		graph,
		pouch,
	)

	if multithreaded:
		_task_pool.queue(task)
		generation_started.emit()
	else:
		generation_started.emit()
		_task_pool.execute(task)


func cancel_generation():
	_task_pool.cancel_all()
	generation_cancelled.emit()


## Emits [signal generation_finished] on the given results of the given [GaeaGenerationTask]
func _execution_task_finished(task: GaeaTask):
	#assert(task_results is GaeaGraph)
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
