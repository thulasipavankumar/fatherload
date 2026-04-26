extends TextureButton


var music_bus = AudioServer.get_bus_index("Master")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_toggle_button_pressed() -> void:
	AudioServer.set_bus_mute(music_bus,not AudioServer.is_bus_mute(music_bus))
