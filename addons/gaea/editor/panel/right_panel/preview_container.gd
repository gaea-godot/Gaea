@tool
class_name GaeaEditorPreviewContainer
extends Control

const DEFAULT_ROTATION: Vector3 = Vector3(-deg_to_rad(30), deg_to_rad(45), 0.0001)

@export var target_world_3d: World3D
@export var view_port: SubViewport
@export var camera: GaeaEditorPreviewCamera
@export var base_mesh: Mesh
@export var container: Node3D

@export var cube_button: Button
@export var quad_button: Button
@export var light_1_button: Button
@export var checkerboard: TextureRect

var multi_mesh_instances: Dictionary[Vector3i, MultiMeshInstance3D]

func _ready() -> void:
	if is_part_of_edited_scene():
		return

	view_port.world_3d = target_world_3d
	container.add_child(build_axis_mesh())
	cube_button.icon = get_theme_icon(&"MaterialPreviewCube", &"EditorIcons")
	quad_button.icon = get_theme_icon(&"MaterialPreviewQuad", &"EditorIcons")
	checkerboard.texture = get_theme_icon(&"Checkerboard", &"EditorIcons")
	light_1_button.icon = get_theme_icon(&"MaterialPreviewLight1", &"EditorIcons")


func _gui_input(event: InputEvent) -> void:
	camera.input(event)


func clear_grid():
	for multi_mesh: MultiMeshInstance3D in multi_mesh_instances.values():
		multi_mesh.multimesh.instance_count = 0
	multi_mesh_instances.clear()


func draw_grid(grid: GaeaGrid, offset: Vector3i, area: AABB, preview_coordinate_format: GaeaGraph.PreviewCoordinateFormat):
	var multimesh: MultiMesh
	if multi_mesh_instances.has(offset):
		multimesh = multi_mesh_instances.get(offset).multimesh
	else:
		var new_instance = MultiMeshInstance3D.new()
		multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_colors = true
		multimesh.mesh = base_mesh
		new_instance.multimesh = multimesh
		multi_mesh_instances.set(offset, new_instance)
		container.call_deferred(&"add_child", new_instance)

	var instance_idx = -1
	var instance_count: int = 0

	# Merge grid if the preview format is Overlay
	if (
		preview_coordinate_format == GaeaGraph.PreviewCoordinateFormat.TOP_DOWN_2D_OVERLAY
		|| preview_coordinate_format == GaeaGraph.PreviewCoordinateFormat.SIDE_SCROLL_2D_OVERLAY
	):
		var overlaied_grid: GaeaGrid = GaeaGrid.new({})
		var layer_indexes: Array[int] = grid.get_enabled_layers_indexes()
		if layer_indexes.size() == 0:
			push_error("Could not generate preview, no enabled layers")
			return

		var layer_map: GaeaValue.Map = GaeaValue.Map.new()
		for layer_idx in layer_indexes:
			var layer: GaeaValue.Map = grid.get_layer(layer_idx)
			for cell in layer.get_cells():
				layer_map.set_cell(cell, layer.get_cell(cell))

		overlaied_grid.add_layer(0, layer_map, GaeaLayer.new())
		grid = overlaied_grid

	# Draw grid
	for layer_idx in grid.get_layers_count():
		instance_count += grid.get_layer(layer_idx).get_cell_count()
	multimesh.instance_count = instance_count

	var convert_method: Callable = _get_convert_method(preview_coordinate_format)
	var layer_offset = Vector3i.ZERO
	for layer_idx in grid.get_layers_count():
		var layer: GaeaValue.Map = grid.get_layer(layer_idx)
		for cell in layer.get_cells():
			instance_idx += 1
			multimesh.set_instance_transform(instance_idx, Transform3D(Basis(), layer_offset + convert_method.call(cell, area)))
			multimesh.set_instance_color(instance_idx, layer.get_cell(cell).preview_color)

		match preview_coordinate_format:
			GaeaGraph.PreviewCoordinateFormat.TOP_DOWN_2D_STACKED:
				layer_offset.y += convert_method.call(area.size, area).y
			GaeaGraph.PreviewCoordinateFormat.SIDE_SCROLL_2D_STACKED:
				layer_offset.z += convert_method.call(area.size, area).z



func _get_convert_method(preview_coordinate_format: GaeaGraph.PreviewCoordinateFormat) -> Callable:
	match preview_coordinate_format:
		GaeaGraph.PreviewCoordinateFormat.TOP_DOWN_2D_OVERLAY, GaeaGraph.PreviewCoordinateFormat.TOP_DOWN_2D_STACKED:
			return _to_top_down_position
		GaeaGraph.PreviewCoordinateFormat.SIDE_SCROLL_2D_OVERLAY, GaeaGraph.PreviewCoordinateFormat.SIDE_SCROLL_2D_STACKED:
			return _to_side_scroll_position
	return _to_perspective_position


func _to_top_down_position(source: Vector3i, _area: AABB) -> Vector3i:
	return Vector3i(source.x, source.z, source.y)


func _to_side_scroll_position(source: Vector3i, area: AABB) -> Vector3i:
	return Vector3i(source.x, int(area.size.y) - source.y, source.z)


func _to_perspective_position(source: Vector3i, _area: AABB) -> Vector3i:
	return source


func build_axis_mesh() -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh := ImmediateMesh.new()

	# Materials (unshaded)
	var mat_x := StandardMaterial3D.new()
	mat_x.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_x.albedo_color = Color.RED

	var mat_y := StandardMaterial3D.new()
	mat_y.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_y.albedo_color = Color.GREEN

	var mat_z := StandardMaterial3D.new()
	mat_z.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_z.albedo_color = Color.BLUE

	# AXES (lines)
	_draw_axis(mesh, mat_x, Vector3.RIGHT)
	_draw_axis(mesh, mat_y, Vector3.UP)
	_draw_axis(mesh, mat_z, Vector3.BACK)

	mesh_instance.mesh = mesh
	return mesh_instance


func _draw_axis(mesh: ImmediateMesh, mat: Material, dir: Vector3):
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(dir * 500.0)
	mesh.surface_end()


func _on_cube_button_pressed() -> void:
	reset_camera_view()


func reset_camera_view() -> void:
	var border: AABB = AABB()
	for multi_mesh: MultiMeshInstance3D in multi_mesh_instances.values():
		border = border.merge(multi_mesh.get_aabb())

	camera.set_camera_view(
		border.position + border.size * 0.5,
		DEFAULT_ROTATION,
		border.size.length() * 0.7
	)
