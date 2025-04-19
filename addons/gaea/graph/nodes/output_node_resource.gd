@tool
extends GaeaNodeResource


func execute(area: AABB, generator_data: GaeaData, generator: GaeaGenerator) -> void:
	log_execute("Start", area, generator_data)

	var grid: GaeaGrid = GaeaGrid.new()
	for layer_idx in generator_data.layers.size():
		var layer_resource: GaeaLayer = generator_data.layers.get(layer_idx)
		if not is_instance_valid(layer_resource) or not layer_resource.enabled:
			grid.add_layer(layer_idx, {}, layer_resource)
			continue

		log_layer("Start", layer_idx, generator_data)

		var grid_data: Dictionary = get_arg(&"layer_%s" % layer_idx, area, generator_data)
		grid.add_layer(layer_idx, grid_data, layer_resource)

		log_layer("End", layer_idx, generator_data)

	log_execute("End", area, generator_data)

	generator.generation_finished.emit.call_deferred(grid)


func get_type() -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func get_scene() -> PackedScene:
	return preload("uid://leflx3tpvb4s")


func get_title_color() -> Color:
	return GaeaEditorSettings.get_configured_output_color()
