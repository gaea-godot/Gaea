@tool
class_name GaeaGenerationSettings
extends Resource

## If [code]true[/code], every time [method generate] is called, a random [member seed] will be chosen.
@export var random_seed_on_generate: bool = true :
	set(value):
		random_seed_on_generate = value
		notify_property_list_changed()

## The seed used for the randomization of the generation.
@warning_ignore("shadowed_global_identifier")
@export var seed: int = randi()

## Leave [param z] as [code]1[/code] for 2D worlds.
@export var world_size: Vector3i = Vector3i(128, 128, 1):
	set(value):
		world_size = value.max(Vector3i.ONE)

## Used with [ChunkLoader]s, or to get the cell position of a node with [method global_to_map].
## Not necessary for generation to work.
@export var cell_size: Vector3i = Vector3i(16, 16, 1):
	set(value):
		cell_size = value.max(Vector3i.ONE)


func _validate_property(property: Dictionary) -> void:
	if property.name == "seed" and random_seed_on_generate:
		property.usage |= PROPERTY_USAGE_READ_ONLY
