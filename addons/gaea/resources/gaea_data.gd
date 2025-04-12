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
@export_storage var connections: Array[Dictionary]
@export_storage var resources: Array[GaeaNodeResource]
@export_storage var node_data: Array[Dictionary]
@export_storage var parameters: Dictionary[StringName, Variant]
@export_storage var scroll_offset: Vector2
@export_storage var other: Dictionary

var generator: GaeaGenerator
var cache: Dictionary[GaeaNodeResource, Dictionary] = {}


func _init() -> void:
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
