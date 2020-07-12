extends TextureButton

func _ready():
    hide()
    
func _on_died():
    show()

func _on_RetryGame_pressed():
    get_tree().reload_current_scene()
