@tool
class_name ToolExample
extends EditorScript

var window: Window

func _run() -> void:
	window= Window.new()
	EditorInterface.popup_dialog(window, Rect2(Vector2(100,100), Vector2(1280,720)))

	var button := Button.new()
	button.text = "Hello"

	window.add_child(button)

	button.pressed.connect(_on_pressed)

	window.close_requested.connect(func():
		window.queue_free()
		)

func _on_close_requested():
	window.queue_free()

func _on_pressed():
	print("pressed")