@tool
extends PopupMenu

enum Action {
	DISCONNECT,
}

@export var graph_edit: GraphEdit

var current_connection: Dictionary


func _ready() -> void:
	hide()
	id_pressed.connect(_on_id_pressed)


func populate(connection: Dictionary) -> void:
	current_connection = connection
	add_item("Disconnect", Action.DISCONNECT)


func _on_id_pressed(id: int) -> void:
	match id:
		Action.DISCONNECT:
			graph_edit.disconnect_node(
				current_connection.from_node,
				current_connection.from_port,
				current_connection.to_node,
				current_connection.to_port
			)
			graph_edit.request_connection_update.emit()
