class_name ThreadedChunkLoader2D
extends ChunkLoader2D
## @experimental
## A threaded version of [ChunkLoader2D], allowing generation code to run parallel to the main thread of your game.

@export var threaded: bool = true

var _queued: Callable
var _task: int = -1


func _process(_delta):
	if _task > -1:
		if WorkerThreadPool.is_task_completed(_task):
			WorkerThreadPool.wait_for_task_completion(_task)
			_task = -1
			run_job(_queued)
	super(_delta)


func _update_loading(actor_position: Vector2i) -> void:
	if not threaded:
		super(actor_position)
	else:
		var job: Callable = func ():
			super._update_loading(actor_position)

		if _task > -1:
			_queued = job
		else:
			run_job(job)


func run_job(job: Callable):
	if job:
		_task = WorkerThreadPool.add_task(job, false, "Load/Unload Chunks")
