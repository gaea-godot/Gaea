@tool
class_name PickRandomGaeaMaterial
extends GaeaMaterial
## A material that randomly selects between multiple materials.
##
## Each material can have a different weight assigned to it, which affects its probability of being selected.[br]
## [br]
## Example:[br]
## [codeblock]
## var random_material = PointwiseRandomGaeaMaterial.new()
## random_material.materials = [grass_material, stone_material]
## random_material.weights = [70.0, 30.0]
## # 70% chance for grass, 30% for stone
## [/codeblock]

## An array of materials to randomly choose from.[br]
## The probability of each material being selected is determined by its corresponding value in the [member weights] array.
@export var materials: Array[GaeaMaterial]:
	set(value):
		var pre_size: int = materials.size()
		materials = value

		#Resize the weights array to match the materials array size
		if materials.size() > pre_size:
			weights.resize(value.size())
			for index in range(pre_size, materials.size()):
				weights[index] = 100.0
		elif materials.size() < pre_size:
			weights.resize(value.size())

		notify_property_list_changed()

## Represents the weight of each material in [member materials].[br]
## Higher values increase the chances of obtaining the material.[br]
@export var weights: PackedFloat32Array:
	#Avoid editing the weights array size
	set(value):
		if value.size() == materials.size():
			weights = value


func _is_sampled() -> bool:
	return false


func _is_data() -> bool:
	return false


## Return the random picked material.
func _get_resource(rng: RandomNumberGenerator) -> GaeaMaterial:
	var material_index: int = rng.rand_weighted(weights)

	if material_index != -1:
		return materials[material_index]
	return null
