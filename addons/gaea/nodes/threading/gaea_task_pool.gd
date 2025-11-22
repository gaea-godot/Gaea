@tool
class_name GaeaTaskPool
extends RefCounted


signal finished(results:GaeaTask)

## The max number of this generator's [GaeaGenerationTask]s that can running in the [WorkerThreadPool] at once.
## All extra tasks will be queued to start as soon as room becomes available.
## A value of Zero means there will be no queue, and all tasks will be sent to the [WorkerThreadPool] immediately.
@export_range(0, 50, 1) var task_limit: int = 0
## The multithreading queue.
## [GaeaExecutionTasks] will wait here until the generator is ready to run them on the [WorkerThreadPool].
var _queued: Array[GaeaTask] = []
## The multithreading tasks currently in progress.
## [GaeaExecutionTasks] are tracked here until they are finished in [method _finish_completed_execution_tasks].
var _tasks: Dictionary[int, GaeaTask] = {}
## For locking shared data; enables proper setting of [ExecutionTask] results.
var _mutex_tasks: Mutex = Mutex.new()
var _main_loop: SceneTree :
	get = _get_main_loop


func _init(on_finished: Callable, _task_limit: int = 0) -> void:
	if is_instance_valid(on_finished) and on_finished.is_valid():
		finished.connect(on_finished)
	task_limit = _task_limit
	_get_main_loop()


func _process() -> void:
	_run_queued_tasks()

func _get_main_loop() -> SceneTree:
	if (_main_loop == null):
		_main_loop = Engine.get_main_loop()
		_get_main_loop().process_frame.connect(_process)
	return _main_loop


func cancel(task:GaeaTask):
	if _queued.has(task):
		_queued.erase(task)
	else:
		task.cancel()


func cancel_all():
	_queued.clear()
	_mutex_tasks.lock()
	for task in _tasks.values():
		task.cancel()
	_mutex_tasks.unlock()


## Send an [GaeaGenerationTask] to the [WorkerThreadPool] to start running immediately.
func _run_task(task:GaeaTask):
	if task.task:
		task.log_run_time()

		# Wait a frame for the UI to update
		await _main_loop.process_frame

		# Spin up a task in the WorkerThreadPool.
		task.task_id = WorkerThreadPool.add_task(
			_execute,
			false, task.description
		)

		# Only wait on the task if it was made successfully.
		if task.task_id != -1:
			_wait_on_task(task)


## A coroutine that adds a task to the task list, wait on it's id,
## then passes it along to be finished.
func _wait_on_task(task: GaeaTask):
	_mutex_tasks.lock()
	_tasks[task.task_id] = task
	_mutex_tasks.unlock()

	# Wait for task completion
	while not WorkerThreadPool.is_task_completed(task.task_id):
		await _main_loop.process_frame

	# Wait on task, then finish it
	WorkerThreadPool.wait_for_task_completion(task.task_id)
	_mutex_tasks.lock()
	_tasks.erase(task.task_id)
	_mutex_tasks.unlock()
	_finish_task(task)


## Sends a new [GaeaGenerationTask] to the [member _task_queue] if the [member _task_limit] has been reached.
## Otherwise run it on the [WorkerThreadPool] immediately.
func queue(task: GaeaTask):
	if task_limit > 0 and _tasks.size() > task_limit:
		# Queue the task to run later.
		task.log_queued_time()
		_queued.push_back(task)
	else:
		# Run the task immediately.
		_run_task(task)


## Executes generation immediately. Blocks the main thread.
func execute(task: GaeaTask):
	task.task_id = 0
	task.log_run_time(false)
	_tasks[0] = task
	_execute(task)
	_finish_task(task)


## Executes the given [GaeaNodeOutput] on the given [member area].
## Passes the resulting [GaeaGrid] to [member task]'s [member GaeaGenerationTask.results].
func _execute(task: GaeaTask = null):
	# Grab task data
	if task == null:
		# Wait till the task can be found using the current task id.
		var task_id: int = WorkerThreadPool.get_caller_task_id()

		while not task:
			_mutex_tasks.lock()
			if _tasks.has(task_id):
				task = _tasks[task_id]
			_mutex_tasks.unlock()

	# Execute
	task.log_start_work()
	var results = task.task.call()

	# Pass back results
	_mutex_tasks.lock()
	task.results = results
	_mutex_tasks.unlock()


## Emits [signal generation_finished] on the given [GaeaGenerationTask]
func _finish_task(task: GaeaTask):
	task.log_finish_time()

	if not task.cancelled:
		finished.emit(task)


## Starts running queued [GaeaGenerationTask]s on the [WorkerThreadPool] as space clears up.
func _run_queued_tasks():
	while (task_limit <= 0 or _tasks.size() < task_limit) and not _queued.is_empty():
		_run_task(_queued.pop_front())
