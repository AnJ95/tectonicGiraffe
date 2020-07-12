extends Node2D

var is_dead = false

func _on_Area2D_area_entered(area):
    
    if is_dead:
        return
        
    if !area.get_parent().is_in_group("Fruit"):
        return
    
    if !area.get_parent().is_grown:
        return
        
    if area.get_parent().is_collected:
        return
    
    get_tree().root.get_node("Main").emit_signal("fruit_collected", area.get_parent())

func dead():
    is_dead = true
