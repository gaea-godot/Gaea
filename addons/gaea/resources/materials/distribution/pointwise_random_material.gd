@tool
@icon("../../../assets/types/sampled_material.svg")
class_name GaeaPointwiseRandomMaterial
extends GaeaPickRandomMaterial
## A material that randomly selects between multiple materials.
##
## Each material can have a different weight assigned to it, which affects its probability of being selected.[br]
## [br]
## Example:[br]
## [codeblock]
## var random_material = GaeaPointwiseRandomMaterial.new()
## random_material.materials = [grass_material, stone_material]
## random_material.weights = [70.0, 30.0]
## # 70% chance for grass, 30% for stone
## [/codeblock]


func _is_sampled() -> bool:
	return true


## Return the random picked material.
func get_sampled_resource(rng: RandomNumberGenerator, _value: float) -> GaeaMaterial:
	return get_resource(rng)
