@tool
class_name GaeaTask
extends RefCounted
## Used to define and track the status of a task within a [GaeaTaskPool].


## A [Callable] representing the "work" to be run in the [GaeaTaskPool].
var task: Callable
## A task ID returned by [method WorkerThreadPool.add_task]. Used to uniquely
## identify this task for management and cleanup in the [GaeaTaskPool]
var task_id: int = -1
## A description used primarily for logging.
var description: String
## A [GaeaPriority] object used for on-demand [member priority_level] calculation.
var priority: GaeaPriority
## The priority level used by [GaeaTaskPool] to sort the task queue.
var priority_level: float:
	get = _get_priority_level
## The time the task was created in msec ticks.
var creation_time: int = -1
## The time the task was placed in the [GaeaTaskPool] queue in msec ticks.
var queued_time: int = -1
## The time the task actually began running in the [WorkerThreadPool] in msec ticks.
var run_time: int = -1
## The time the task was finished and cleaned up by the [GaeaTaskPool].
var finish_time: int = -1
## Whether to print logging to the Output console.
var log_enabled: bool = false
## A cancellation token used to indicate that a [GaeaTask] will be
## discarded by the [GaeaTaskPool] without sending it
## via [signal GaeaTaskPool.task_finished].
var cancelled: bool = false
## The output of calling [member task], or null for [Callable]s with a [void]
## return type.
var results: Variant:
	set = _set_results,
	get = _get_results


func _init(_task: Callable, _description: String, enable_log: bool = false, _priority:GaeaPriority = null):
	task = _task
	description = _description
	creation_time = Time.get_ticks_msec()
	log_enabled = enable_log
	priority = _priority


#region Priority
func _get_priority_level() -> float:
	return priority.level if priority else float(creation_time)
#endregion


#region Results
func _set_results(value) -> void:
	results = value


func _get_results() -> Variant:
	return results
#endregion


#region Cancellation
## Triggers the cancellation token [member cancelled].
func cancel() -> void:
	cancelled = true
	_on_cancel()


func _on_cancel() -> void:
	pass
#endregion


#region Comparison
## Compares this [GaeaTask] with [param other].
## By default, returns true when [param other] has a later
## [member creation_time].
func compare(other: GaeaTask) -> bool:
	return _compare(other)


func _compare(other: GaeaTask) -> bool:
	return creation_time < other.creation_time


## Returns true if [param other] is equivalent. By default, returns
## true when [param other] has a matching [member task].
func equals(other: GaeaTask) -> bool:
	return _equals(other)


func _equals(other: GaeaTask) -> bool:
	return task == other.task
#endregion


#region Logging
## Called when [GaeaTaskPool] discards a [GaeaTask].
func log_discarded():
	if log_enabled:
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Discard %s." % [
			description
		])


## Called when [GaeaTaskPool] cancels a [GaeaTask].
func log_cancelled():
	finish_time = Time.get_ticks_msec()
	if log_enabled:
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Cancelled %s." % [
			description
		])


## Called when [GaeaTaskPool] queues a [GaeaTask].
func log_queued_time():
	queued_time = Time.get_ticks_msec()
	if log_enabled:
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Queued %s at time %.2f" % [
			description,
			roundi(float(queued_time) * 0.001)
		])


## Called when [GaeaTaskPool] starts running a [GaeaTask].
func log_run_time(multithreaded: bool = true):
	run_time = Time.get_ticks_msec()
	if log_enabled:
		if queued_time != -1:
			GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Running %s after %.0f ms in queue (priority %f)" % [
				description,
				(run_time - queued_time),
				priority_level,
			])
		else:
			GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Running %s immediately on %s thread (priority %f)" % [
				description,
				"side" if multithreaded else "main",
				priority_level,
			])


## Called when [GaeaTaskPool] calls a [GaeaTask]'s [member task].
func log_start_work():
	if log_enabled:
		GaeaGraph.print_log.call_deferred(GaeaGraph.Log.THREADING, "Working %s as task %d" % [
			description,
			WorkerThreadPool.get_caller_task_id()
		])


## Called when [GaeaTaskPool] emits [signal GaeaTaskPool.task_finished]
## and cleans up a [GaeaTask].
func log_finish_time():
	finish_time = Time.get_ticks_msec()
	if log_enabled:
		var has_run_time: bool = run_time >= 0
		var start_time: int = run_time if has_run_time else creation_time
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Finished %s after %.0f ms%s. Total lifetime %.0f ms.%s" %
		[
			description,
			(finish_time - start_time),
			" in WorkerThreadPool" if has_run_time else "",
			(finish_time - creation_time),
			" (Canceled)" if cancelled else ""
		])
#endregion
