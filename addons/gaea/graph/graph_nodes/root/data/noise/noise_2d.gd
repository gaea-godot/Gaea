@tool
extends GaeaNodeNoise
class_name GaeaNodeNoise2D



func _get_title() -> String:
	return "Noise2D"


func _get_description() -> String:
	return super() + "\n[b]Ignores the z axis.[/b]"


func _get_noise_value(cell: Vector3i, noise: FastNoiseLite) -> float:
	return noise.get_noise_2d(cell.x, cell.y)
