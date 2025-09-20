@tool
extends GaeaNodeNoise
class_name GaeaNodeNoise3D


func _get_title() -> String:
	return "Noise3D"


func _get_noise_value(cell: Vector3i, noise: FastNoiseLite) -> float:
	return noise.get_noise_3d(cell.x, cell.y, cell.z)
