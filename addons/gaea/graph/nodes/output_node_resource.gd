@tool
extends GaeaNodeResource


func execute(area: AABB, generator_data: GaeaData, generator: GaeaGenerator) -> void:
	log_execute("Start", area, generator_data)

	var grid: GaeaGrid = GaeaGrid.new()
	for layer_idx in generator_data.layers.size():
		var map_connected_idx: int = get_connected_resource_idx(layer_idx)
		if map_connected_idx == -1:
			continue

		var map_input_resource: GaeaNodeResource = generator_data.resources[map_connected_idx]
		var layer_resource: GaeaLayer = generator_data.layers.get(layer_idx)
		if not is_instance_valid(layer_resource) or not layer_resource.enabled or not is_instance_valid(map_input_resource):
			grid.add_layer(layer_idx, {}, layer_resource)
			continue
		
		log_layer("Start", layer_idx, generator_data)

		var grid_data: Dictionary = map_input_resource.traverse(
			get_connected_port_to(layer_idx), area, generator_data
		)
		grid.add_layer(layer_idx, grid_data, layer_resource)
		
		log_layer("End", layer_idx, generator_data)
	
	log_execute("End", area, generator_data)
	
	generator.generation_finished.emit.call_deferred(grid)


func get_type() -> GaeaGraphNode.SlotTypes:
	return GaeaGraphNode.SlotTypes.NULL


static func get_scene() -> PackedScene:
	return preload("res://addons/gaea/graph/nodes/output_node.tscn")


func get_title_color() -> Color:
	var color: Color = Color("421926")
	color.v *= 1.5
	return color
