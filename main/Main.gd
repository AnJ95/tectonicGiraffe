extends Node2D

const ZOOM_PER_FRUIT = 1.02
const CAM_OFFSET_PER_FRUIT = -5
signal fruit_collected(fruit)

onready var giraffe = $Giraffe
onready var camera = $Camera2D
onready var jingle = $Jingle
onready var tequeMix = $TequeMix
onready var treePolygon:Polygon2D = $TreePolygon
onready var labelScore = $UI/Score
onready var tweenZoom = $TweenZoom
onready var tweenSound = $TweenSound

onready var Fruit = preload("res://fruit/Fruit.tscn")

var score = 0

func _ready():
    connect("fruit_collected", self, "_on_fruit_collected")
    giraffe.connect("dead", self, "_on_dead")
    giraffe.connect("dead", $UI/RetryGame, "_on_dead")
    
    $UI/Tutorial.connect("tutorial_done", giraffe, "_on_tutorial_done")

func _on_dead():
    tweenSound.interpolate_property(tequeMix, "volume_db", tequeMix.volume_db, -80, 3)
    tweenSound.start()
    
func _on_fruit_collected(fruit):
    call_deferred("spawn_fruit")
    if fruit != null:
        score += 1
        labelScore.text = str(score) if score >= 10 else "0" + str(score)
        
        var new_zoom = camera.zoom * ZOOM_PER_FRUIT
        if new_zoom.x > 1.2:
            new_zoom.x = 1.2
            new_zoom.y = 1.2
        else:
            tweenZoom.interpolate_property(camera, "offset:y", camera.offset.y, camera.offset.y + CAM_OFFSET_PER_FRUIT, 0.6)
        tweenZoom.interpolate_property(camera, "zoom", camera.zoom, new_zoom, 0.6)
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
    
    var allowedRect:Rect2 = get_camera_rect()
    #var allowedRect:Rect2 = camera.get_viewport().get_visible_rect()
    #var allowedRect:Rect2 = get_viewport().get_visible_rect()
    allowedRect = allowedRect.grow(-50)
    
    while (!allowedRect.has_point(pos) or !treePolygon.has_point(pos)):
        pos = giraffe.calc_random_reachable_pos()
    
    fruit.global_position = pos

func get_camera_rect():
    # Get the canvas transform
    var ctrans = get_canvas_transform()
    
    var min_pos = -ctrans.get_origin() / ctrans.get_scale()
    
    # The maximum edge is obtained by adding the rectangle size.
    # Because it's a size it's only affected by zoom, so divide by scale too.
    var view_size = get_viewport_rect().size / ctrans.get_scale()
    var max_pos = min_pos + view_size
    
    return Rect2(min_pos, max_pos - min_pos)


