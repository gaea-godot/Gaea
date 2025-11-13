@tool
class_name GaeaMainEditor
extends Control

## Emitted when the about popup is requested.
@warning_ignore("unused_signal")
signal about_popup_request()
signal popup_create_node_request()
signal popup_create_node_and_connect_node_request(node: GaeaGraphNode, type: GaeaValue.Type)

signal popup_node_context_menu_at_mouse_request(selected_nodes: Array)
signal popup_link_context_menu_at_mouse_request(connection: Dictionary)
@warning_ignore("unused_signal")
signal panel_popout_request()

signal node_selected_for_creation(resource: GaeaNodeResource)
signal special_node_selected_for_creation(id: StringName)
signal new_reroute_requested(connection: Dictionary)


@export var gaea_panel: GaeaPanel
@export var graph_edit: GaeaGraphEdit
@export var about_window: AcceptDialog
@export var create_node_popup: GaeaPopupCreateNode
@export var node_context_menu: GaeaPopupNodeContextMenu
@export var link_context_menu: GaeaPopupLinkContextMenu


## Local position on [GraphEdit] for a node that may be created in the future.
var node_creation_target: Vector2 = Vector2.ZERO
var created_node_connect_to: GaeaGraphNode = null
var created_node_connect_to_port: int = -1
var dragged_from_left: bool = false


func _ready() -> void:
	node_selected_for_creation.connect(graph_edit._on_node_selected_for_creation)
	new_reroute_requested.connect(graph_edit._on_new_reroute_requested)
	special_node_selected_for_creation.connect(graph_edit._on_special_node_selected_for_creation)

	popup_create_node_request.connect(create_node_popup._on_popup_create_node_request)
	popup_create_node_and_connect_node_request.connect(create_node_popup._on_popup_create_node_and_connect_node_request)
	special_node_selected_for_creation.connect(create_node_popup._on_special_node_selected_for_creation)

	popup_node_context_menu_at_mouse_request.connect(node_context_menu._on_popup_node_context_menu_at_mouse_request)

	popup_link_context_menu_at_mouse_request.connect(link_context_menu._on_popup_link_context_menu_at_mouse_request)


## Move a [param popup] windows at the current mouse position and clamp it inside the main windows
func move_popup_at_mouse(popup: Window) -> void:
	if EditorInterface.get_editor_settings().get_setting("interface/editor/single_window_mode"):
		popup.position = get_viewport().get_mouse_position()
		_clamp_popup_in_rect(popup, get_viewport().get_visible_rect())
	else:
		popup.position = DisplayServer.mouse_get_position()
		var window = get_window()
		_clamp_popup_in_rect(popup, Rect2i(window.position, window.size))


static func _clamp_popup_in_rect(popup: Window, window_rect: Rect2i) -> void:
	var inner_rect = Rect2i(popup.position, popup.size)
	if inner_rect.position.x < window_rect.position.x:
		popup.position.x = window_rect.position.x
	elif inner_rect.position.x + inner_rect.size.x > window_rect.position.x + window_rect.size.x:
		popup.position.x = window_rect.position.x + window_rect.size.x - inner_rect.size.x

	if inner_rect.position.y < window_rect.position.y:
		popup.position.y = window_rect.position.y
	elif inner_rect.position.y + inner_rect.size.y > window_rect.position.y + window_rect.size.y:
		popup.position.y = window_rect.position.y + window_rect.size.y - inner_rect.size.y
