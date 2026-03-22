@abstract
class_name GaeaChunkLoaderActor
extends Resource


@abstract
func get_actor_chunk_position(chunk_loader: GaeaChunkLoader, chunk_size: Vector3i) -> Vector3i


@abstract
func is_actor_valid(chunk_loader: GaeaChunkLoader) -> bool


func _get_chunk_position(actor_position: Vector3, chunk_size: Vector3i) -> Vector3i:
	return Vector3i(
		floori(float(actor_position.x) / chunk_size.x),
		floori(float(actor_position.y) / chunk_size.y),
		floori(float(actor_position.z) / chunk_size.z),
	)
