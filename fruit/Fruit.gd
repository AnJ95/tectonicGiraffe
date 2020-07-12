extends Node2D

export(Gradient) var rot_gradient:Gradient

onready var sprite = $Sprite
onready var progress = $TextureProgress
onready var animationPlayer = $AnimationPlayer

var is_grown = false
var is_collected = false

var lifetime_max = 12.0
var lifetime = 0.0

func _ready():
    progress.min_value = 0
    progress.max_value = lifetime_max
    progress.step = lifetime_max / 100.0
    
    sprite.scale = Vector2(0,0)
    
    animationPlayer.connect("animation_finished", self, "done_growing")
    animationPlayer.play("grow")
    progress.hide()

func done_growing(_d):
    progress.show()
    $Area2D.monitorable = true
    is_grown = true
    
func _process(delta):
    if !is_grown:
        return
        
    lifetime += delta
    
    progress.value = lifetime_max - lifetime
    sprite.modulate = rot_gradient.interpolate(lifetime / lifetime_max)
    
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
    
