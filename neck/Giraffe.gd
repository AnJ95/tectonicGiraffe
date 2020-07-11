extends Node2D

onready var Seg = preload("res://neck/Seg.tscn")
onready var head = $Neck/Head

var time = 0

func _ready():
    randomize()
    for i in range(3):
        add_segment()

func _process(delta):
    time += delta
    
func add_segment():
    # add new segment to heads parent
    var seg = Seg.instance().init(self)
    head.get_parent().add_child(seg)
    
    # reparent head to new segment
    head.get_parent().remove_child(head)
    seg.add_child(head)
    head.position = seg.get_next_seg_local_pos()
    
func calc_random_reachable_pos():
    var clone = self.duplicate()
    print(clone.head.global_position)
