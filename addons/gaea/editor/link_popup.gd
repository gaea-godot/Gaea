@tool
extends PopupMenu

enum Action {
	DISCONNECT,
	INSERT_NEW_REROUTE
}

@export var graph_edit: GraphEdit

var current_connection: Dictionary

signal new_reroute_requested(connection: Dictionary)


func _ready() -> void:
	hide()
	id_pressed.connect(_on_id_pressed)


func populate(connection: Dictionary) -> void:
	current_connection = connection
	add_item("Disconnect", Action.DISCONNECT)
	add_item("Insert New Reroute", Action.INSERT_NEW_REROUTE)
	size = get_contents_minimum_size()

func _on_id_pressed(id: int) -> void:
	match id:
		Action.DISCONNECT:
			graph_edit.disconnection_request.emit(
				current_connection.from_node,
				current_connection.from_port,
				current_connection.to_node,
				current_connection.to_port
			)
		Action.INSERT_NEW_REROUTE:
			new_reroute_requested.emit(current_connection)
