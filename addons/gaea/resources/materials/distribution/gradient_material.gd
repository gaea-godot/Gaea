@tool
class_name GradientGaeaMaterial
extends GaeaMaterial


signal points_sorted

@export var materials: Array[GaeaMaterial]:
	get:
		var value: Array[GaeaMaterial]
		for point: Dictionary in points:
			value.append(point.get(&"material"))
		return value
	set(value):
		var pre_size: int = materials.size()

		if value.size() > pre_size:
			points.append({&"material": null, &"offset": 0.0})
		elif value.size() < pre_size:
			for material in materials:
				if value.count(material) != materials.count(material):
					points.remove_at(materials.find(material))

		for idx: int in value.size():
			if idx >= points.size():
				break
			points.get(idx).set(&"material", value.get(idx))

		_sort_points()


@export var offsets: PackedFloat32Array:
	get:
		return PackedFloat32Array(points.map(func(point: Dictionary) -> float: return point.get(&"offset", 0.0)))
	set(value):
		var new_offsets := value.duplicate()
		new_offsets.sort()

		if new_offsets == offsets:
			return

		if value.size() == materials.size():
			for idx: int in value.size():
				points.get(idx).set(&"offset", value.get(idx))

		_sort_points()


@export_storage var points: Array[Dictionary]


func _init() -> void:
	super()
	points.append({&"material": null, &"offset": 0.0})
	notify_property_list_changed()


func _sort_points() -> void:
	points.sort_custom(
		func(point_a: Dictionary, point_b: Dictionary) -> bool:
			return point_a.get(&"offset", 0.0) < point_b.get(&"offset", 0.0)
	)
	points_sorted.emit()


func _is_sampled() -> bool:
	return true


func _is_data() -> bool:
	return false


func _get_sampled_resource(_rng: RandomNumberGenerator, value: float) -> GaeaMaterial:
	for idx: int in points.size():
		var next_point_offset: float
		if (idx + 1) >= points.size():
			next_point_offset = INF
		else:
			next_point_offset = points.get(idx + 1).get(&"offset", INF)
		if value < next_point_offset:
			return points.get(idx).get(&"material")
	return null
