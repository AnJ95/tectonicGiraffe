extends Node2D

export(Gradient) var rot_gradient

var is_collected = false

    
func _on_fruit_collected(fruit):
    if fruit != self:
        return
    
    if is_collected:
        return
    
    is_collected = true
    call_deferred("queue_free")
    
