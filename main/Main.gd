extends Node2D

signal fruit_collected(fruit)

onready var giraffe = $Giraffe

onready var Fruit = preload("res://fruit/Fruit.tscn")

func _ready():
    connect("fruit_collected", self, "_on_fruit_collected")

func _on_fruit_collected(_fruit):
    call_deferred("spawn_fruit")

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
    fruit.global_position = giraffe.calc_random_reachable_pos()
