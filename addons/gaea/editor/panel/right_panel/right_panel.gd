@tool
class_name GaeaEditorPreviewPanel
extends Control

const GENERATION_TOOLTIP: String = "Press generate to see result"

@export var main_view: GaeaEditorMainView
@export var preview_container: GaeaEditorPreviewContainer
@export var bottom_label: Label
@export var bottom_container: VBoxContainer
@export var generate_button: Button
@export var directional_light_1: DirectionalLight3D

var generation_in_progress: bool = false
var _generation_start_time: int
var _generation_cumulated_time: int
var _chunk_generated: int
var _chunk_generation_count: int
var _do_camera_reset: bool = true
var _task_pool: GaeaTaskPool

func _on_light_1_toggled(toggled_on: bool) -> void:
	directional_light_1.visible = toggled_on


func _on_generate_button_pressed() -> void:
	if generation_in_progress:
		return
	generate_button.disabled = true
	generation_in_progress = true

	preview_container.clear_grid()

	var graph: GaeaGraph = main_view.graph_edit.graph

	var chunk_offsets: Array[Vector3] = _get_chunk_offsets(graph)
	chunk_offsets.sort_custom(func(a: Vector3i, b: Vector3i):
		return a.length_squared() < b.length_squared()
	)
	_chunk_generation_count = chunk_offsets.size()
	_generation_start_time = Time.get_ticks_msec()
	_generation_cumulated_time = 0
	_chunk_generated = 0

	if _task_pool == null:
		_task_pool = GaeaTaskPool.new()
		_task_pool.task_finished.connect(_execution_task_finished)

	_task_pool.task_limit = GaeaGenerationPriority.get_recommended_task_limit(_chunk_generation_count)

	var settings: GaeaGenerationSettings = GaeaGenerationSettings.new()
	settings.cell_size = graph.preview_chunk_size
	settings.world_size = graph.preview_chunk_size
	settings.random_seed_on_generate = false
	settings.seed = graph.preview_seed

	for offset in chunk_offsets:
		var area = AABB(offset, graph.preview_chunk_size)
		var pouch: GaeaGenerationPouch = GaeaGenerationPouch.new(settings, area)
		var task: GaeaGenerationTask = GaeaGenerationTask.new(
			"Execute on %s" % area,
			graph,
			pouch
		)

		_task_pool.queue(task)

	bottom_label.text = "Generating %d chunks in %d threads." % [
		_chunk_generation_count,
		_task_pool.task_limit
	]


func _get_chunk_offsets(graph: GaeaGraph) -> Array[Vector3]:
	@warning_ignore("integer_division")
	var grid_size: Vector3i = graph.preview_world_size / graph.preview_chunk_size
	var list: Array[Vector3] = []
	var chunk_size = Vector3(graph.preview_chunk_size)
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			for z in range(grid_size.z):
				var offset: Vector3 = Vector3(x, y, z)
				offset *= chunk_size
				list.append(offset)
				if list.size() >= graph.preview_chunk_count:
					return list
	return list



func _execution_task_finished(task: GaeaTask) -> void:
	_chunk_generated += 1
	_generation_cumulated_time += task.finish_time - task.run_time
	var graph: GaeaGraph = main_view.graph_edit.graph
	var exec: GaeaGenerationTask = task as GaeaGenerationTask
	var area = exec.pouch.area
	var data: GaeaGrid = exec.results

	preview_container.draw_grid(data, area.position, area, graph.preview_coordinate_format)
	generation_in_progress = false
	generate_button.disabled = false

	if _chunk_generated == _chunk_generation_count:
		bottom_label.text = "Generated %d chunks in %d ms (%d ms / chunk)" % [
			_chunk_generated,
			Time.get_ticks_msec() - _generation_start_time,
			roundi(float(_generation_cumulated_time) / _chunk_generation_count)
		]
		_task_pool = null
		if _do_camera_reset:
			_do_camera_reset = false
			preview_container.reset_camera_view()
	else:
		bottom_label.text = "Generating %d/%d chunks in %d threads." % [
			_chunk_generated,
			_chunk_generation_count,
			_task_pool.task_limit
		]


func reset() -> void:
	_task_pool = null
	preview_container.clear_grid()
	preview_container.reset_camera_view()
	bottom_label.text = GENERATION_TOOLTIP
	generate_button.disabled = false
	_do_camera_reset = true
