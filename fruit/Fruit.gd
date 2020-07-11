extends Node2D

export(Gradient) var rot_gradient:Gradient

onready var modulator = $Modulator
onready var progress = $Modulator/TextureProgress

var is_collected = false

var lifetime_max = 12.0
var lifetime = 0.0

func _ready():
    progress.min_value = 0
    progress.max_value = lifetime_max
    progress.step = lifetime_max / 100.0
    
func _process(delta):
    lifetime += delta
    
    progress.value = lifetime_max - lifetime
    modulator.modulate = rot_gradient.interpolate(lifetime / lifetime_max)
    
    if lifetime >= lifetime_max:
        get_tree().root.get_node("Main").emit_signal("fruit_collected", null)
        get_parent().remove_child(self)
        queue_free()
    
func _on_fruit_collected(fruit):
    if fruit != self:
        return
    
    if is_collected:
        return
    
    is_collected = true
    call_deferred("queue_free")
    
