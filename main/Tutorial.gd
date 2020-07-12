extends Node2D

signal tutorial_done()

func show_text(text):
    $Label.text = text
    $Tween.interpolate_property(self, "modulate:a", modulate.a, 1, 0.8)
    $Tween.start()

func hide_text():
    $Tween.interpolate_property(self, "modulate:a", 1, 0, 0.8)
    $Tween.start()

var tutorial_stage = 0
func _on_TimerTutorial_timeout():
    tutorial_stage += 1
    
    if tutorial_stage == 3:
        hide_text()
        
    if tutorial_stage == 4:
        show_text("Collect Fruits before they rot")
        
    if tutorial_stage == 7:
        hide_text()
        
    if tutorial_stage == 8:
        show_text("Don't run out of spots")
        emit_signal("tutorial_done")
    
    if tutorial_stage == 11:
        hide_text()
        $TimerTutorial.stop()
