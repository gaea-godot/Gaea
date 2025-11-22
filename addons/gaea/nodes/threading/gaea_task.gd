@tool
class_name GaeaTask
extends RefCounted

var task: Callable
var task_id: int = -1
var description: String
var creation_time: float = -1.0
var queued_time: float = -1.0
var run_time: float = -1.0
var finish_time: float = -1.0
var log_enabled: bool = false
var cancelled: bool = false
var results: Variant:
	set = _set_results,
	get = _get_results


func _init(_task: Callable, _description: String, enable_log: bool = false):
	task = _task
	description = _description
	creation_time = Time.get_ticks_msec()
	log_enabled = enable_log


func _set_results(value) -> void:
	results = value


func _get_results() -> Variant:
	return results


func cancel() -> void:
	cancelled = true
	_on_cancel()


func _on_cancel() -> void:
	pass


func log_queued_time():
	queued_time = Time.get_ticks_msec()
	if log_enabled:
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Queued %s at time %d" % [
			description,
			queued_time
		])


func log_run_time(multithreaded: bool = true):
	run_time = Time.get_ticks_msec()
	if log_enabled:
		if queued_time != -1:
			GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Running %s after %.2d ms in queue" % [
				description,
				run_time - queued_time
			])
		else:
			GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Running %s immediately on %s thread" % [
				description,
				"side" if multithreaded else "main"
			])


func log_start_work():
	if log_enabled:
		GaeaGraph.print_log.call_deferred(GaeaGraph.Log.THREADING, "Working %s as task %d" % [
			description,
			WorkerThreadPool.get_caller_task_id()
		])


func log_finish_time():
	finish_time = Time.get_ticks_msec()
	if log_enabled:
		var has_run_time := run_time >= 0
		var start_time = run_time if has_run_time else creation_time
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Finished %s after %.2d ms%s. %s" %
		[
			description,
			finish_time - start_time,
			" in WorkerThreadPool" if has_run_time else "",
			"(Canceled)" if cancelled else ""
		])
