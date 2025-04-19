@tool
@icon("../assets/data.svg")
class_name GaeaData
extends Resource


signal layer_count_modified

enum Log { None=0, Execute=1, Traverse=2, Data=4, Args=8 }

@export var layers: Array[GaeaLayer] = [GaeaLayer.new()] :
	set(value):
		layers = value
		layer_count_modified.emit()
		emit_changed()
@export_group("Debug")
@export_flags("Execute", "Traverse", "Data", "Args") var logging:int = Log.None
## List of all connections between nodes. The value contain the following properties.
## [codeblock]
## {
##    from_node: int, # Index of the node in [member resources]
##    from_port: int, # Index of the port of the node
##    to_node: int,   # Index of the node in [member resources]
##    to_port: int,   # Index of the port of the node
##    keep_alive: bool
## }
## [/codeblock]
@export_storage var connections: Array[Dictionary]
@export_storage var resource_uids: Array[String]
var resources: Array[GaeaNodeResource]
@export_storage var node_data: Array[Dictionary]
@export_storage var parameters: Dictionary[StringName, Variant]
@export_storage var other: Dictionary

var generator: GaeaGenerator
var cache: Dictionary[GaeaNodeResource, Dictionary] = {}
var scroll_offset: Vector2

func _init() -> void:
	resource_local_to_scene = true
	notify_property_list_changed()


func get_parameter(name: StringName) -> Variant:
	return _get(name)


func set_parameter(name: StringName, value: Variant) -> void:
	_set(name, value)


func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary]
	list.append({
		"name": "Parameters",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
	})
	for variable in parameters.values():
		if variable == null:
			parameters.erase(parameters.find_key(variable))
			continue

		list.append(variable)

	return list


func _set(property: StringName, value: Variant) -> bool:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property and typeof(value) == variable.type:
			variable.value = value
			return true
	return false


func _get(property: StringName) -> Variant:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property:
			return variable.value
	return


func _setup_local_to_scene() -> void:
	#Data migration from 2.0 beta. See PR #305. Remove before releasing 2.X.
	if resources.size() > 0:
		_migrate_data()
	resources = []
	for idx in resource_uids.size():
		var base_uid = resource_uids[idx]
		var data: Dictionary = node_data[idx]
		var resource: GaeaNodeResource = load(base_uid)
		if not resource is GaeaNodeResource:
			push_error("Something went wrong, the resource at %s is not a GaeaNodeResource" % base_uid)
			return
		resource = resource._instantiate_duplicate()
		resource._load_save_data(data)
		resources.append(resource)


#region Migration from previous save format
## Data migration from 2.0 beta. See PR #305. Remove before releasing 2.X.
## @deprecated
func _migrate_data() -> void:
	var node_map := get_all_nodes_files("res://addons/gaea/graph/nodes/root/")
	resource_uids = []
	for idx in resources.size():
		var resource = resources[idx]
		var data = node_data[idx]
		if node_map.has(resource.title):
			resource_uids.append(node_map.get(resource.title))
		elif resource.title.left(7) == "Reroute":
			resource_uids.append("uid://kdn03ei2yp6e")
		elif resource.title == "Output":
			resource_uids.append("uid://bbkdvyxkj2slo")
		else:
			resource_uids.append("uid://kdn03ei2yp6e")
			push_error("Could not migrate node '%s'" % resource.title)
		if resource.data:
			data.set("data", resource.data)
		if resource.salt:
			data.set("salt", resource.salt)
		node_data[idx] = data

## Data migration from 2.0 beta. See PR #305. Remove before releasing 2.X.
## @deprecated
func get_all_nodes_files(path: String, files: Dictionary[String, String] = {}) -> Dictionary[String, String]:
	var dir : = DirAccess.open(path)

	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				# recursion
				files = get_all_nodes_files(dir.get_current_dir() + "/" + file_name, files)
			else:
				if file_name.get_extension() != "tres":
					file_name = dir.get_next()
					continue

				var node_path = dir.get_current_dir() + "/" + file_name
				var node = ResourceLoader.load(node_path)
				files.set(node.title, ResourceUID.id_to_text(ResourceLoader.get_resource_uid(node_path)))
			file_name = dir.get_next()
	else:
		push_error("Can't open directory %s." % path)
	return files
#endregion
