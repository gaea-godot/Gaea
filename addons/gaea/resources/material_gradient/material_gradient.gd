@tool
class_name GaeaMaterialGradient
extends Resource


var preview: Gradient = Gradient.new()
@export var materials: Array[GaeaMaterial]:
	set(value):
		var pre_size: int = materials.size()
		materials = value

		if materials.size() > pre_size:
			offsets.resize(value.size())
			for index in range(pre_size, materials.size()):
				offsets[index] = 0.0
		elif materials.size() < pre_size:
			offsets.resize(value.size())

		_update_preview()
		notify_property_list_changed()

@export var offsets: PackedFloat32Array:
	set(value):
		if value.size() == materials.size():
			offsets = value
			_update_preview()


func sample(value: float) -> GaeaMaterial:
	value = clampf(value, 0.0, 1.0)
	var material: GaeaMaterial

	for offset: float in offsets:
		value -= offset
		if value <= 0.0:
			return materials[offsets.find(offset)]

	return material


func _update_preview() -> void:
	preview.offsets = offsets
	preview.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	for material in materials:
		var color: Color = Color.TRANSPARENT
		if is_instance_valid(material):
			color = material.preview_color
		preview.colors[materials.find(material)] = color
		print(preview.colors)
