extends Node2D

const ZOOM_PER_FRUIT = 1.02
const CAM_OFFSET_PER_FRUIT = -5
signal fruit_collected(fruit)

onready var giraffe = $Giraffe
onready var camera = $Camera2D
onready var tweenZoom = $TweenZoom
onready var jingle = $Jingle
onready var Fruit = preload("res://fruit/Fruit.tscn")

func _ready():
    connect("fruit_collected", self, "_on_fruit_collected")
    
func _on_fruit_collected(fruit):
    call_deferred("spawn_fruit")
    if fruit != null:
        tweenZoom.interpolate_property(camera, "offset:y", camera.offset.y, camera.offset.y + CAM_OFFSET_PER_FRUIT, 0.6)
        tweenZoom.interpolate_property(camera, "zoom", camera.zoom, camera.zoom * ZOOM_PER_FRUIT, 0.6)
        tweenZoom.start()
        jingle.play(0)
        
        
var spawns_left = 5
func _on_Timer_timeout():
    if spawns_left == 0:
        $Timer.stop()
        return
    spawn_fruit()
    spawns_left -= 1

func spawn_fruit():
    var fruit = Fruit.instance()
    connect("fruit_collected", fruit, "_on_fruit_collected")
    add_child(fruit)
    
    var pos = Vector2(-100, 0)
    var allowedRect:Rect2 = camera.get_viewport().get_visible_rect()
    #var allowedRect:Rect2 = get_viewport().get_visible_rect()
    allowedRect = allowedRect.grow(-50)
    
    while (!allowedRect.has_point(pos)):
        pos = giraffe.calc_random_reachable_pos()
    
    fruit.global_position = pos
