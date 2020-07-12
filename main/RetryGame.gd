extends TextureButton

func _ready():
    hide()
    
func _on_dead():
    modulate.a = 0
    show()
    $Tween.interpolate_property(self, "modulate:a", 0, 1, 0.6)
    $Tween.start()

func _on_RetryGame_pressed():
    get_tree().reload_current_scene()
