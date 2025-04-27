@icon("../../assets/chunk_loader.svg")
class_name ChunkLoader2D
extends Node


@export var generator: GaeaGenerator
@export var actor: Node2D
@export var chunk_size: Vector2i = Vector2i(16, 16)
@export var loading_radius: Vector2i = Vector2i(2, 2)
@export_group("Advanced")
## Amount of miliseconds the loader waits before it checks if new chunks need to be loaded.
@export_range(0, 1, 1, "or_greater", "suffix:ms") var update_rate: int = 0
## Executes the loading process on ready [br]
## [b]Warning:[/b] No chunks might load if set to false.
@export var load_on_ready: bool = true
## If set to true, the Chunk Loader unloads chunks left behind
@export var unload_chunks: bool = true
## If set to true, will prioritize chunks closer to the [param actor].
@export var load_closest_chunks_first: bool = true

var _last_run: int = 0
var _last_position: Vector2i
var _loaded_chunks: Array[Vector2]


func _ready() -> void:
	generator.request_reset()
	if load_on_ready:
		_update_loading(actor.global_position)


func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec()
	if current_time - _last_run > update_rate:
		_try_loading()
		_last_run = current_time


func _try_loading() -> void:
	var actor_position: Vector2i = _get_actor_position()

	if actor_position == _last_position:
		return

	_last_position = actor_position
	_update_loading(actor_position)


func _update_loading(actor_position: Vector2i) -> void:
	var required_chunks: Array[Vector2] = _get_required_chunks(actor_position)

	if unload_chunks:
		for chunk in _loaded_chunks:
			if not required_chunks.has(chunk):
				generator.request_area_erasure(AABB(
					Vector3(chunk.x * chunk_size.x, chunk.y * chunk_size.y, 0),
					Vector3i(chunk_size.x, chunk_size.y, 1)
				))

	for required in required_chunks:
		_loaded_chunks.append(required)
		generator.generate_area(AABB(
			Vector3(required.x * chunk_size.x, required.y * chunk_size.y, 0),
			Vector3i(chunk_size.x, chunk_size.y, 1)
		))


func _get_actor_position() -> Vector2i:
	var actor_position := Vector2.ZERO
	if is_instance_valid(actor):
		actor_position = actor.global_position

	var map_position := generator.global_to_map(Vector3(actor_position.x, actor_position.y, 0.0))
	var chunk_position := Vector2i(floori(float(map_position.x) / chunk_size.x), floori(float(map_position.y) / chunk_size.y))
	return chunk_position


func _get_required_chunks(actor_position: Vector2i) -> Array[Vector2]:
	var chunks: Array[Vector2] = []

	var x_range = range(actor_position.x - abs(loading_radius).x, actor_position.x + abs(loading_radius).x + 1)
	var y_range = range(actor_position.y - abs(loading_radius).y, actor_position.y + abs(loading_radius).y + 1)

	for x in x_range:
		for y in y_range:
			chunks.append(Vector2(x, y))

	if load_closest_chunks_first:
		chunks.sort_custom(
			func(chunk1: Vector2, chunk2: Vector2): return (
				chunk1.distance_squared_to(actor_position) < chunk2.distance_squared_to(actor_position)
			)
		)
	return chunks
