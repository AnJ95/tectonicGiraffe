extends AudioStreamPlayer2D

func _process(delta):
    global_position = get_tree().get_nodes_in_group("Head")[0].global_position
