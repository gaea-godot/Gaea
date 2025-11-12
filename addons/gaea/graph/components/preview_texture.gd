@tool
extends TextureRect

const RESOLUTION: Vector2i = Vector2i(64, 64)

var selected_output: StringName = &""
var node: GaeaGraphNode
var slider_container: HBoxContainer
var slider: HSlider
var slider_label: SpinBox


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	expand_mode = EXPAND_FIT_HEIGHT_PROPORTIONAL
	stretch_mode = STRETCH_KEEP_ASPECT

	await get_tree().process_frame

	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	slider_container = HBoxContainer.new()

	slider_label = SpinBox.new()
	slider_label.step = 0.01
	slider_label.min_value = 0.0
	slider_label.max_value = 1.0

	slider = HSlider.new()
	slider.step = 0.001
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider_label.value_changed.connect(slider.set_value_no_signal)
	slider_label.value_changed.connect(update.unbind(1))
	slider.value_changed.connect(update.unbind(1))
	slider.value_changed.connect(slider_label.set_value_no_signal)
	slider.allow_greater = true
	slider.allow_lesser = true

	slider_label.allow_greater = true
	slider_label.allow_lesser = true

	slider_container.add_child(slider)
	slider_container.add_child(slider_label)

	get_parent().add_child(slider_container)

	var preview_resolution = GaeaEditorSettings.get_preview_resolution()
	texture = ImageTexture.create_from_image(Image.create_empty(preview_resolution, preview_resolution, true, Image.FORMAT_RGBA8))

func toggle(for_output: StringName) -> void:
	if not get_parent().visible:
		get_parent().show()
		slider_container.visible = (
			node.resource.get_output_port_type(for_output) == GaeaValue.Type.SAMPLE
		)
		selected_output = for_output
		update()
	else:
		if selected_output == for_output:
			selected_output = &""
		get_parent().hide()

	node.auto_shrink.call_deferred()


func update() -> void:
	if not is_visible_in_tree():
		return

	var preview_resolution: int = GaeaEditorSettings.get_preview_resolution()
	var resolution: Vector2i = Vector2i(preview_resolution, preview_resolution)
	var preview_max_sim: int = GaeaEditorSettings.get_preview_max_simulation_size()
	var sim_size:Vector3
	#match (node.resource._get_preview_simulation_size()):
	#	GaeaNodeResource.SimSize.WORLD:
	#		sim_size = Vector3(resolution.x * 2, resolution.y * 2, 1).min(Vector3(preview_max_sim, preview_max_sim, preview_max_sim))
	#	_: # GaeaNodeReousrce.SimSize.Preview is the default
	#		sim_size = Vector3(resolution.x, resolution.y, 1)
	sim_size = Vector3(resolution.x, resolution.y, 1).min(Vector3(preview_max_sim, preview_max_sim, preview_max_sim))

	var generation_settings = GaeaGenerationSettings.new()
	generation_settings.world_size = sim_size
	generation_settings.cell_size = sim_size
	# TMP until we have a proper seed management
	generation_settings.random_seed_on_generate = false
	generation_settings.seed = 123456

	var pouch: GaeaGenerationPouch = GaeaGenerationPouch.new(generation_settings, AABB(Vector3.ZERO, sim_size))
	var data: GaeaValue.GridType = node.resource.traverse(
		selected_output,
		node.graph_edit.graph,
		pouch
	).get("value")
	pouch.clear_all_cache()


	if not is_instance_valid(data):
		texture = null


	var sim_center:Vector3i = sim_size / 2
	var res_center:Vector3i = Vector3i(resolution.x, resolution.y, 0) / 2
	var sim_offset := sim_center.max(res_center) - sim_center.min(res_center)

	var image: Image = Image.create_empty(resolution.x, resolution.y, true, Image.FORMAT_RGBA8)
	for x: int in resolution.x:
		for y: int in resolution.y:
			var color: Color
			var value = data.get_cell(Vector3i(x, y, 0) + sim_offset)
			if value == null:
				continue
			match node.resource.get_output_port_type(selected_output):
				GaeaValue.Type.SAMPLE:
					if typeof(value) != TYPE_FLOAT or is_nan(value):
						continue
					color = Color(value, value, value, 1.0 if value >= slider.value else 0.0)
				GaeaValue.Type.MAP:
					if value is not GaeaMaterial or not is_instance_valid(value):
						continue
					color = value.preview_color
				_:
					continue
			image.set_pixelv(Vector2i(x, y), color)

	texture = ImageTexture.create_from_image(image)
