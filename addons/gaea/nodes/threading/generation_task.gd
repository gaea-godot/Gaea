@tool
class_name GaeaGenerationTask
extends GaeaTask
## Facilitates [GaeaGraph] execution in a way that can be queued and
## managed by [GaeaTaskPool].


## The [GaeaGenerationPouch] passed to this task's [GaeaGraph] execution.
var pouch: GaeaGenerationPouch

var _results_dict: Dictionary[int, GaeaValue.Map]


## Sets [member task] equal to a bound [Callable] created from
## [param graph]'s execute method and sets [member priority] to a
## [GaeaGenerationPriority] using [param origin] and
## [param task_pouch]'s [member GaeaGenerationPouch.area].
## [br] See [member GaeaGenerationPriority._origin] for [member origin] type.
func _init(task_description: String, graph: GaeaGraph, task_pouch: GaeaGenerationPouch, origin: Variant = null):
	var new_task = graph.get_output_node().execute.bind(graph, task_pouch)
	self.pouch = task_pouch
	super._init(
		new_task, task_description,
		graph.is_log_enabled(GaeaGraph.Log.THREADING),
		GaeaGenerationPriority.new(origin, task_pouch.area),
	)


#region Results
func _set_results(value) -> void:
	_results_dict = value.get_grid_data()


func _get_results() -> Variant:
	return GaeaGrid.new(_results_dict)
#endregion


#region Cancellation
## Sets [member GaeaGenerationPouch.cancelled] when [method cancel] is called.
func _on_cancel() -> void:
	if is_instance_valid(pouch):
		pouch.cancelled = true
#endregion


#region Comparison
## Compares based on [member priority_level].
func _compare(other: GaeaTask) -> bool:
	return priority_level < other.priority_level


## Return true if both [member task] and [member pouch]'s [member GaeaGenerationPouch.area] match.
func _equals(other: GaeaTask) -> bool:
	return pouch.area == other.pouch.area and super._equals(other)
#endregion
