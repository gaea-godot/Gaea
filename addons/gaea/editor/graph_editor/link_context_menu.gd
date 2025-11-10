@tool
class_name GaeaPopupLinkContextMenu
extends PopupMenu

enum Action { DISCONNECT, INSERT_NEW_REROUTE }

@export var main_editor: GaeaMainEditor

var current_connection: Dictionary


func _ready() -> void:
	if is_part_of_edited_scene():
		return
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
			main_editor.graph_edit.disconnection_request.emit(
				current_connection.from_node,
				current_connection.from_port,
				current_connection.to_node,
				current_connection.to_port
			)
		Action.INSERT_NEW_REROUTE:
			main_editor.new_reroute_requested.emit(current_connection)


func _on_popup_link_context_menu_at_mouse_request(connection: Dictionary) -> void:
	clear()
	populate(connection)
	main_editor.node_creation_target = main_editor.graph_edit.get_local_mouse_position()
	main_editor.move_popup_at_mouse(self)
	popup()
