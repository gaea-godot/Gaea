@tool
extends Control


enum ExportDirectory {
	COMMON,
	IMAGES,
	MARKDOWN,
}

const DOC_CLASS_URL: String = "[%s](https://docs.godotengine.org/en/latest/classes/class_%s.html)"
const ARGUMENTS_HEADER_LINK := "#arguments"
const SLOT_TYPES_LINK := "../the-basics/anatomy-of-a-graph.md#slot-types"


@onready var tree := %Tree
@onready var sub_viewport: SubViewport = %SubViewport
@onready var open_folder_button: Button = %OpenFolderButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var markdown: RichTextLabel = %Markdown

var graph_edit: GaeaEditorGraphEdit


func _ready() -> void:
	if not is_part_of_edited_scene():
		open_folder_button.icon = (
			EditorInterface.get_base_control().get_theme_icon(&"Folder", &"EditorIcons")
		)

	graph_edit = GaeaEditorGraphEdit.new()
	graph_edit.populate(GaeaGraph.new())


func _capture_resource(resource: GaeaNodeResource) -> void:
	var node: GaeaEditorGraphNode = resource.get_scene().instantiate()
	node.graph_edit = graph_edit
	if resource.get_scene_script() != null:
		node.set_script(resource.get_scene_script())
	node.resource = resource
	node.graph_edit = graph_edit
	var file_name: String = _get_file_name(resource)
	await _take_image(node, file_name)
	_take_markdown(resource, file_name)


func _capture_frame() -> void:
	var frame: GaeaEditorGraphFrame = GaeaEditorGraphFrame.new()
	frame.graph_edit = graph_edit
	await _take_image(frame, "Frame")


func _take_image(node: GraphElement, file_name: String) -> void:
	sub_viewport.add_child(node)

	await get_tree().create_timer(0.01).timeout

	var path: String = _get_export_directory(ExportDirectory.IMAGES) + file_name + ".png"

	sub_viewport.size = node.size + Vector2(32, 32)
	node.position = Vector2(16, 16)

	await get_tree().create_timer(0.01).timeout

	var image := sub_viewport.get_viewport().get_texture().get_image()
	image.save_png(path)

	await get_tree().process_frame

	node.queue_free()
	sub_viewport.size = Vector2.ONE


func _take_markdown(resource: GaeaNodeResource, file_name: String) -> void:
	var path: String = _get_export_directory(ExportDirectory.MARKDOWN) + file_name + ".md"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(_get_node_documentation(resource))
	file.close()


func _on_tree_node_selected_for_creation(resource: GaeaNodeResource) -> void:
	_capture_resource(resource)
	EditorInterface.get_editor_toaster().push_toast("Node %s exported." % resource.get_title())


func _on_capture_all_button_pressed() -> void:
	confirmation_dialog.popup_centered()


func _capture_all_children(tree_item: TreeItem) -> int:
	var count: int = 0
	for item in tree_item.get_children():
		if item.get_metadata(0) is GaeaNodeResource:
			count += 1
			await _capture_resource(item.get_metadata(0))
		elif item.get_metadata(0) is StringName:
			count += 1
			await _capture_frame()
		elif item.get_metadata(0) == null:
			count += await _capture_all_children(item)
	return count


func _on_open_folder_button_pressed() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(_get_export_directory(ExportDirectory.COMMON)))


func _on_confirmation_dialog_confirmed() -> void:
	EditorInterface.get_editor_toaster().push_toast("Exporting nodes...")
	var count: int = await _capture_all_children(tree.get_root())
	_capture_resource(GaeaNodeOutput.new())
	EditorInterface.get_editor_toaster().push_toast("%d nodes exported." % count)


func _on_tree_special_node_selected_for_creation(id: StringName) -> void:
	if id == &"frame":
		_capture_frame()


func _on_tree_node_selected(resource: GaeaNodeResource) -> void:
	markdown.text = _get_node_documentation(resource)


func _get_node_documentation(resource: GaeaNodeResource) -> String:
	if not is_instance_valid(resource) or resource is GaeaNodeOutput:
		return ""

	var text: String = ""
	var data: Dictionary[String, String] = {}
	var type_metadata: String = GaeaValue.get_type_string(resource.get_type())
	data.set("type", type_metadata)
	data.set("image_path", _get_file_name(resource))

	var node_path: String = resource.get_script().resource_path
	node_path = node_path.get_base_dir()
	node_path = node_path.trim_prefix(tree.NODES_FOLDER_PATH)
	node_path = node_path.trim_prefix(GaeaProjectSettings.get_custom_nodes_path())
	data.set("category", " > ".join(Array(node_path.split("/")).map(func(part: String): return part.capitalize())))

	var extra_title = resource.get_extra_documentation(GaeaNodeResource.DocumentationSection.TITLE)
	if not extra_title.is_empty():
		data.set("title", resource.get_tree_name() + " " + extra_title)
	else:
		data.set("title", resource.get_tree_name())
	data.set("description", resource.get_description())

	var template: String = """---
template: node.html
type: {type}
image: {image_path}
category: {category}
---

# {title}

## Description

{description}
"""
	text = template.format(data)

	var get_extra = func(section: GaeaNodeResource.DocumentationSection) -> String:
		var extra: String = resource.get_extra_documentation(section)
		if extra.is_empty():
			return ""
		return "\n" + extra + "\n"

	text += get_extra.call(GaeaNodeResource.DocumentationSection.DESCRIPTION)

	# Enums
	if resource.get_enums_count() > 0:
		text += "\n## Enums\n"
		for enum_index in resource.get_enums_count():
			text += "\n### %s\n" % resource.get_enum_title(enum_index)
			text += "\n%s\n" % resource.get_enum_description(enum_index)
			for enum_value: int in resource.get_enum_options(enum_index).values():
				text += "\n- %s" % [resource.get_enum_option_display_name(enum_index, enum_value)]
			text += "\n"
	text += get_extra.call(GaeaNodeResource.DocumentationSection.ENUMS)

	# Arguments
	var arguments: Array[StringName] = resource.get_arguments_list()
	if arguments.size() > 0:
		text += "\n## Arguments\n"
		var headers: Array[String] = ["Type", "Name (Display Name)", "Description", "Default"]
		var rows: Array[Array] = []
		var column_size: Array[int] = [4, 4, 11, 7]
		for arg_name: String in arguments:
			if resource.get_argument_type(arg_name) == GaeaValue.Type.CATEGORY:
				continue


			var display_name: String = resource.get_argument_display_name(arg_name)
			var name_column: String = "`%s`" % arg_name
			if not display_name.is_empty():
				name_column = "`%s` (%s)" % [arg_name, display_name]

			var current_row: Array[String] = [
				"[%s](%s)" % [
					GaeaValue.get_type_string(resource.get_argument_type(arg_name)),
					SLOT_TYPES_LINK
				],
				name_column,
				resource.get_argument_description(arg_name)
			]

			var default_value: Variant = resource.get_argument_default_value(arg_name)
			if default_value is GaeaValue.GridType:
				current_row.append("")
			elif default_value is Dictionary or default_value is Array:
				if resource.get_argument_type(arg_name) == GaeaValue.Type.RANGE:
					current_row.append("%s-%s" % [
						default_value.get("min", "N/A"),
						default_value.get("max", "N/A")
					])
				else:
					current_row.append(JSON.stringify(default_value))
			else:
				current_row.append(var_to_str(default_value))

			for col_idx in current_row.size():
				current_row[col_idx] = _bbcode_to_markdown(current_row[col_idx])

			rows.append(current_row)
			for col_idx in column_size.size():
				column_size[col_idx] = maxi(column_size.get(col_idx), current_row.get(col_idx).length())

		var line_format: String = "| %%-%ds | %%-%ds | %%-%ds | %%-%ds |\n" % column_size
		text += line_format % headers
		text += "|" + ("|".join(column_size.map(func(r_size: int): return "-".repeat(r_size + 2)))) + "|\n"
		for row in rows:
			text += line_format % row
	text += get_extra.call(GaeaNodeResource.DocumentationSection.ARGUMENTS)

	var outputs: Array[StringName] = resource.get_output_ports_list()
	if outputs.size() > 0:
		text += "\n## Outputs\n"
		for output in outputs:
			var display_name: String = resource.get_output_port_display_name(output)
			var header: String = "`%s`" % output
			if not display_name.is_empty():
				header = "`%s` (%s)" % [output, display_name]

			text += "\n### [%s](%s) - %s\n" % [
				GaeaValue.get_type_string(resource.get_output_port_type(output)),
				SLOT_TYPES_LINK,
				header,
			]
			text += "\n" + resource.get_output_port_description(output)
	text += get_extra.call(GaeaNodeResource.DocumentationSection.OUTPUTS)

	return _bbcode_to_markdown(text)


func _get_file_name(resource: GaeaNodeResource) -> String:
	var file_name: String = resource.get_title()
	if resource.get_tree_name() != file_name:
		file_name += resource.get_tree_name()

	var parenthesis_start := file_name.find("(")
	if parenthesis_start != -1:
		file_name = file_name.erase(parenthesis_start, 99)

	return file_name.to_pascal_case()


func _get_export_directory(target: ExportDirectory) -> String:
	var dir: DirAccess = DirAccess.open("user://")
	if not dir.dir_exists("documentation_toolkit"):
		dir.make_dir("documentation_toolkit")
	dir = DirAccess.open("user://documentation_toolkit")

	if target == ExportDirectory.COMMON:
		return "user://documentation_toolkit/"

	var sub_path: String = "node_" + String(ExportDirectory.find_key(target)).to_snake_case()
	if not dir.dir_exists(sub_path):
		dir.make_dir(sub_path)
	return "user://documentation_toolkit/" + sub_path + "/"


func _bbcode_to_markdown(input: String) -> String:
	input = input.replace("[code]", "`").replace("[/code]", "`")

	# Find all [tag] to replace
	var regex := RegEx.new()
	regex.compile("\\[(?<name>[^\\]]+)\\][^\\(]")
	var tags: Array[String] = []
	for result: RegExMatch in regex.search_all(input):
		var tag: String = result.get_string("name")
		if not tags.has(tag):
			tags.append(tag)

	for tag: String in tags:
		if ClassDB.class_exists(tag):
			input = input.replace("[%s]" % tag, DOC_CLASS_URL % [tag, tag.to_lower()])
		elif tag.begins_with("Gaea"):
			input = input.replace("[%s]" % tag, tag)
	var param_regex := RegEx.new()
	param_regex.compile("\\[param ([^\\]]+)\\]")
	input = param_regex.sub(input, "[$1](%s)" % ARGUMENTS_HEADER_LINK, true)

	return input.replace("[code]", "`").replace("[/code]", "`")
