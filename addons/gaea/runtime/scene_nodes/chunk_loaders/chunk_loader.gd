@tool
@icon("../../../assets/chunk_loader.svg")
class_name GaeaChunkLoader
extends Node


@export var generator: GaeaGenerator

@export var actor: GaeaChunkLoaderActor

@export var chunk_size: Vector3i = Vector3i(16, 16, 1):
	set(value):
		chunk_size = value.abs().max(Vector3i.ONE)

@export var loading_radius: Vector3i = Vector3i(2, 2, 1):
	set(value):
		loading_radius = value.abs().max(Vector3i.ONE)

@export_group("Advanced")
## Amount of miliseconds the loader waits before it checks if new chunks need to be loaded.
## A value of 0.0 mean the loader will check each frames.
@export_range(0.0, 1.0, 0.1, "or_greater", "suffix:s") var update_rate: float = 0.1:
	set(value):
		update_rate = value
		if is_instance_valid(_run_timer):
			_run_timer.wait_time = value

## Executes the loading process on ready [br]
## [b]Warning:[/b] No chunks might load if set to false.
@export var start_on_ready: bool = true

## If set to true, the Chunk Loader unloads chunks left behind
@export var unload_chunks: bool = true


var _last_chunk_position: Vector3i = Vector3i.MAX
var _loaded_chunks: Array[Vector3i]
var _run_timer: Timer


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	generator.request_reset()
	_run_timer = Timer.new()
	_run_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_run_timer.ignore_time_scale = true
	_run_timer.wait_time = update_rate
	_run_timer.timeout.connect(_try_loading)
	add_child(_run_timer)
	if start_on_ready:
		start()


func start() -> void:
	if not is_instance_valid(actor) or not actor.is_actor_valid(self):
		push_error("Invalid actor provided. Stopping the ChunkLoader node at '%s'.", get_path())
		return
	_run_timer.start(0)
	_try_loading()


func stop() -> void:
	_run_timer.stop()


func _try_loading() -> void:
	var chunk_position: Vector3i = actor.get_actor_chunk_position(self, chunk_size)
	if chunk_position == _last_chunk_position:
		return
	_update_loading(chunk_position)


func _update_loading(chunk_position: Vector3i) -> void:
	var required_chunks: Array[Vector3i] = _get_chunks_in_loading_radius(chunk_position)

	if unload_chunks:
		var unloaded_chunks: Array[Vector3i]
		for chunk: Vector3i in _loaded_chunks:
			if not required_chunks.has(chunk):
				generator.request_area_erasure(_get_area_at(chunk))
				unloaded_chunks.append(chunk)
		for unloaded_chunk in unloaded_chunks:
			_loaded_chunks.erase(unloaded_chunk)

	for required in required_chunks:
		if not _loaded_chunks.has(required):
			_loaded_chunks.append(required)
			generator.generate_area(_get_area_at(required), chunk_position)

	_last_chunk_position = chunk_position
	generator.task_pool.notify_priority_changed()


func _get_chunks_in_loading_radius(chunk_position: Vector3i) -> Array[Vector3i]:
	var chunks: Array[Vector3i] = []
	var x_range = range(chunk_position.x - loading_radius.x, chunk_position.x + loading_radius.x + 1)
	var y_range = range(chunk_position.y - loading_radius.y, chunk_position.y + loading_radius.y + 1)
	var z_range = range(chunk_position.z - loading_radius.z, chunk_position.z + loading_radius.z + 1)

	for z in z_range:
		for y in y_range:
			for x in x_range:
				chunks.append(Vector3i(x, y, z))
	return chunks


func _get_area_at(position: Vector3) -> AABB:
	return AABB(
		Vector3(position.x * chunk_size.x, position.y * chunk_size.y, position.z * chunk_size.z),
		Vector3i(chunk_size.x, chunk_size.y, chunk_size.z)
	)
