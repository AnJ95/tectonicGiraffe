extends Node2D

onready var Seg = preload("res://neck/Seg.tscn")
onready var head = $Neck/Head

var time = 0
var is_clone = false

func _ready():
    
    get_parent().connect("fruit_collected", self, "_on_fruit_collected")
    
    randomize()
    for i in range(3):
        add_segment()
    


func _process(delta):
    time += delta
    

func _on_fruit_collected(_fruit):
    call_deferred("add_segment")
    
func add_segment():
    # add new segment to heads parent
    var seg = Seg.instance().init(self)
    head.get_parent().add_child(seg)
    
    # reparent head to new segment
    head.get_parent().remove_child(head)
    seg.add_child(head)
    head.position = seg.get_next_seg_local_pos()
    
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
