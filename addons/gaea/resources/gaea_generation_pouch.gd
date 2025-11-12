@tool
class_name GaeaGenerationPouch
extends RefCounted

## Class used to handle various data during generation like generated area, seed and cache.

## Area to generate.
var area: AABB: get = get_area

## Generation settings used for this generation. This property should be treated as read-only deeply.
var settings: GaeaGenerationSettings: get = get_settings

# Cache used during generation to avoid recalculating data unnecessarily.
# The inner dictionary keys are the slot output port names, and the values are the cached data.
var _cache: Dictionary[GaeaNodeResource, Dictionary] = {}


func _init(generation_settings: GaeaGenerationSettings, generation_area: AABB) -> void:
	_cache.clear()
	settings = generation_settings
	area = generation_area


func get_area() -> AABB:
	return area


func get_settings() -> GaeaGenerationSettings:
	return settings


## Clear all data from the cache.
func clear_all_cache() -> void:
	_cache.clear()


## Clear the cached data for a specific node.
func clear_cache(node: GaeaNodeResource):
	if _cache.has(node):
		_cache.erase(node)


## Checks if the cache has data corresponding to the [param node], then if it has it for output_port.
func has_cache(node: GaeaNodeResource, output_port: StringName) -> bool:
	return _cache.has(node) and _cache[node].has(output_port)


## Adds or sets data to the cache for [param node], then output_port index.
## This is called during [method traverse] if [method GaeaNodeResource._use_caching] returns [code]true[/code],
## but can also be called in special cases where you want to manually add cached values.
func set_cache(node: GaeaNodeResource, output_port: StringName, new_data: Variant) -> void:
	var node_cache: Dictionary = _cache.get_or_add(node, {})
	node_cache[output_port] = new_data


## Gets cached data by [param node], then output_port index.
## Assumes that data exists, will error out if it doesn't.
## See also [method has_cached_data]
func get_cache(node: GaeaNodeResource, output_port: StringName) -> Variant:
	return _cache[node][output_port]
