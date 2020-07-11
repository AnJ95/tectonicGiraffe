extends Node2D

onready var Seg = preload("res://neck/Seg.tscn")

func _ready():
    var root = $Giraffe/Neck
    
    randomize()
    for i in range(3):
        var seg = Seg.instance()
        root.add_child(seg)
        root = seg
