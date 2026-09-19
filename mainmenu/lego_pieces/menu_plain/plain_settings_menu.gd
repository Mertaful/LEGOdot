extends Control

@onready var back_button: Button = %BackButton


func _ready() -> void:
	if back_button:
		var back_lambda = func() :
			get_parent().remove_child(self)
			queue_free()
		back_button.pressed.connect(back_lambda)
