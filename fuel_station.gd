extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FuelUI.hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Entered fuel station")
	$FuelUI.show()
	pass

func _on_area_2d_body_exited(body: Node2D) -> void:
	$FuelUI.hide()
	pass 

func _on_button_pressed() -> void:
	# refill if user has cash 1$ = 1 unit of fuel
	pass 
