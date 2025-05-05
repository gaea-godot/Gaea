extends EditorInspectorPlugin


const GradientVisualizer = preload("res://addons/gaea/editor/gradient_visualizer.gd")


func _can_handle(object: Object) -> bool:
	return object is GradientGaeaMaterial


func _parse_begin(object: Object) -> void:
	if object is GradientGaeaMaterial:
		var gradient_visualizer := GradientVisualizer.new()
		gradient_visualizer.gradient = object

		add_custom_control(gradient_visualizer)

		gradient_visualizer.update()
		object.points_sorted.connect(gradient_visualizer.update)
