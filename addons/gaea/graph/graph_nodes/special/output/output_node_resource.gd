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


func _get_title() -> String:
	return "Output"


func _get_arguments_list() -> Array[StringName]:
	if not is_instance_valid(node) or not is_instance_valid(node.generator):
		return []

	var layers: Array[StringName]
	for layer_idx in node.generator.data.layers.size():
		layers.append(&"%d" % layer_idx)

	return layers


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_argument_display_name(arg_name: StringName) -> String:
	if not is_instance_valid(node) or not is_instance_valid(node.generator):
		return ""

	var idx: int = int(arg_name)
	if node.generator.data.layers.size() < idx:
		return "Invalid Layer"

	var layer: GaeaLayer = node.generator.data.layers.get(idx)

	if not is_instance_valid(layer):
		return "[color=RED](%d) Missing GaeaLayer resource[/color]" % idx

	var layer_name: String
	if not layer.resource_name.is_empty():
		layer_name = "(%d) %s" % [idx, layer.resource_name]
	else:
		layer_name = "(%d) Layer %s" % [idx, idx]

	if not layer.enabled:
		layer_name = "[color=DIM_GRAY][s]%s[/s][/color]" % layer_name

	return layer_name


func _get_argument_connection(arg_name: StringName) -> Dictionary:
	var idx = int(arg_name)
	for connection in connections:
		if connection.to_port == idx:
			return connection
	return {}


## Start generation for [param area], and emit the [param generator]'s [signal GaeaGenerator.generation_finished]
## signal when done.
func execute(area: AABB, graph: GaeaGraph, generator: GaeaGenerator) -> void:
	_log_execute("Start", area, graph)

	var grid: GaeaGrid = GaeaGrid.new()
	for layer_idx in graph.layers.size():
		var layer_resource: GaeaLayer = graph.layers.get(layer_idx)
		if not is_instance_valid(layer_resource) or not layer_resource.enabled:
			grid.add_layer(layer_idx, {}, layer_resource)
			continue

		_log_layer("Start", layer_idx, graph)

		var grid_data: Dictionary = _get_arg(&"%d" % layer_idx, area, graph)
		grid.add_layer(layer_idx, grid_data, layer_resource)

		_log_layer("End", layer_idx, graph)

	_log_execute("End", area, graph)

	generator.generation_finished.emit.call_deferred(grid)


# Custom scene that dynamically adds layer slots.
func _get_scene_script() -> GDScript:
	return load("uid://34dullcgrsk7")


## Output nodes have a special titlebar color.
func get_title_color() -> Color:
	return GaeaEditorSettings.get_configured_output_color()


func _get_output_ports_list() -> Array[StringName]:
	return []


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func _get_data(_output_port: StringName, _area: AABB, _graph: GaeaGraph) -> Variant:
	return null
