@tool
extends GaeaNodeResource
class_name GaeaNodeOutput
## Outputs the generated grid via [signal GaeaGenerator.generation_finished].
##
## All Gaea graphs should lead to this node. When a generation is needed,
## [method execute] is called in the corresponding graph's Output node. This method
## uses [method traverse] to get the generated grid for each layer, constructs a
## [GaeaGrid] object with it and finally emits the [signal GaeaGenerator.generation_finished] signal
## to pass that grid to listener nodes.[br][br]
## This node can't and shouldn't be deleted.


## Start generation for [param area], and emit the [param generator]'s [signal GaeaGenerator.generation_finished]
## signal when done.
func execute(area: AABB, generator_data: GaeaData, generator: GaeaGenerator) -> void:
	_log_execute("Start", area, generator_data)

	var grid: GaeaGrid = GaeaGrid.new()
	for layer_idx in generator_data.layers.size():
		var layer_resource: GaeaLayer = generator_data.layers.get(layer_idx)
		if not is_instance_valid(layer_resource) or not layer_resource.enabled:
			grid.add_layer(layer_idx, {}, layer_resource)
			continue

		_log_layer("Start", layer_idx, generator_data)

		var grid_data: Dictionary = _get_arg(&"layer_%s" % layer_idx, area, generator_data)
		grid.add_layer(layer_idx, grid_data, layer_resource)

		_log_layer("End", layer_idx, generator_data)

	_log_execute("End", area, generator_data)

	generator.generation_finished.emit.call_deferred(grid)


# Custom scene that dynamically adds layer slots.
func _get_scene() -> PackedScene:
	return preload("uid://leflx3tpvb4s")


## Output nodes have a special titlebar color.
func get_title_color() -> Color:
	return GaeaEditorSettings.get_configured_output_color()
