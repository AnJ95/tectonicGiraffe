extends Node2D

signal dead()

onready var Seg = preload("res://neck/Seg.tscn")
onready var SegClass = preload("res://neck/Seg.gd")

onready var tweenHealth = $TweenHealth

const HEALTH_PER_FRUIT = 2.0
const HEALTH_PER_SECOND = -0.32

onready var head = $Neck/Head

var dead = false

var time = 0
var is_clone = false

var num_segs = 0
var health = 1
var cur_max_health = 1

func _ready():
    
    get_parent().connect("fruit_collected", self, "_on_fruit_collected")
    
    randomize()
    for i in range(3):
        add_segment()
        
    connect("dead", head, "dead")
    
func _process(delta):
    time += delta
    
    set_health(health + delta * HEALTH_PER_SECOND)

func _on_fruit_collected(fruit):
    if fruit == null:
        return
    call_deferred("add_segment", true)
    
func add_segment(show_start_anim=false):
    # add new segment to heads parent
    var seg = Seg.instance().init(self, show_start_anim)
    head.get_parent().add_child(seg)
    
    # reparent head to new segment
    head.get_parent().remove_child(head)
    seg.add_child(head)
    head.position = seg.get_next_seg_local_pos()
    
    connect("dead", seg, "dead")
    
    # health
    num_segs += 1
    cur_max_health = SegClass.HEALTH_PER_SEG * num_segs
    if show_start_anim:
        if tweenHealth.is_active():
            tweenHealth.stop_all()
        tweenHealth.interpolate_method(self, "set_health", health, health + HEALTH_PER_FRUIT, 0.6)
        tweenHealth.start()
    else:
        set_health(health + HEALTH_PER_FRUIT)
    
func died():
    if !dead:
        emit_signal("dead")
        $DeathPlayer.play()
    dead = true

func set_health(new_health):
    if new_health < 0:
        died()
    
    health = clamp(new_health, 0, cur_max_health)
    for child in $Neck.get_children():
        if child.is_in_group("Seg"):
            child.set_health(health)
    
func calc_random_reachable_pos():
    set_all_angles_random()
    
    var pos = head.global_position
    
    restore_all_angles()
    
    return pos

func set_all_angles_random():
    # iterate from head to body
    var seg = head.get_parent()
    while seg.is_in_group("Seg"):
        seg.set_angle_random()
        seg = seg.get_parent()
        
func restore_all_angles():
    # iterate from head to body
    var seg = head.get_parent()
    while seg.is_in_group("Seg"):
        seg.restore_angle()
        seg = seg.get_parent()
