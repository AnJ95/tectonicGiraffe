extends Node2D



func _on_Area2D_area_entered(area):
    
    if !area.get_parent().is_in_group("Fruit"):
        return
    
    if !area.get_parent().is_grown:
        return
        
    if area.get_parent().is_collected:
        return
    
    get_tree().root.get_node("Main").emit_signal("fruit_collected", area.get_parent())
