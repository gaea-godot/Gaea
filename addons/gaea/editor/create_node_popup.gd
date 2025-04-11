extends Window


@onready var cancel_button: Button = %CancelButton


func _ready() -> void:
	close_requested.connect(hide)
	cancel_button.pressed.connect(hide)
