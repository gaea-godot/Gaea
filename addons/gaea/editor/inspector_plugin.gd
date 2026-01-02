extends EditorInspectorPlugin

const GradientVisualizer = preload("uid://cwaqlwiy2t1pe")
const GeneratorButtons = preload("uid://dm42lg3fiyqub")

var _panel: GaeaPanel


func _init(panel: GaeaPanel) -> void:
	_panel = panel


func _can_handle(object: Object) -> bool:
	return (
		object is GradientGaeaMaterial
		or object is GaeaGenerator
	)


func _parse_begin(object: Object) -> void:
	if object is GaeaGenerator:
		var callable: Callable = _on_graph_changed.bind(object)
		if not object.graph_changed.is_connected(callable):
			object.graph_changed.connect(callable)

	if object is GradientGaeaMaterial:
		var gradient_visualizer := GradientVisualizer.new()
		gradient_visualizer.gradient = object

		add_custom_control(gradient_visualizer)

		gradient_visualizer.update()
		object.points_sorted.connect(gradient_visualizer.update)


func _parse_category(object: Object, category: String) -> void:
	if object is GaeaGenerator:
		if category == &"generator.gd":
			var generator_buttons := GeneratorButtons.new()
			generator_buttons.generator = object

			add_custom_control(generator_buttons)


func _on_graph_changed(old_graph: GaeaGraph, generator: GaeaGenerator) -> void:
	if not is_instance_valid(old_graph) or not is_instance_valid(generator):
		return

	var scene_path: String = generator.get_tree().edited_scene_root.scene_file_path
	if old_graph.resource_path.begins_with(scene_path):
		_panel.file_list.set_unsaved(old_graph)
