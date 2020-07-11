extends Node2D

############################################
# CUSTOMIZATION

export(float) var angle_initial = 0.0

export(float) var angle_speed_left = 0.7
export(float) var angle_speed_right = 0.7
export(float) var angle_delta_left = 0.0
export(float) var angle_delta_right = 0.0

export(float) var angle_wiggle_left = 0.0
export(float) var angle_wiggle_right = 0.0
export(float) var wiggle_period = 1.0

export(float) var width = 10
export(float) var length = 40

############################################
# NODES

onready var line = $Visual/Line
onready var circle = $Visual/Circle

############################################
# STATE

var time = 0.0
var angle = 0

func _ready():
    randomize_properties()
    
    var par = get_parent()
    if par and par.is_in_group("Seg"):
        position = par.get_next_seg_local_pos()
    
    angle = angle_initial
    rotation = angle
    
    line.rect_size = Vector2(width, length)
    line.rect_position = Vector2(-width/2, -length)
    
    var s = width / float(circle.texture.get_width())
    circle.scale = Vector2(s, s)
    circle.position = Vector2(0, -length)

func _process(delta):
    if Input.is_action_pressed("rotate_left"):
        angle -= angle_speed_left * delta
    if Input.is_action_pressed("rotate_right"):
        angle += angle_speed_right * delta

    angle = clamp(angle, angle_initial - angle_delta_left, angle_initial + angle_delta_right)
    
    time += delta
    var wiggle = sin((2*PI) * time / wiggle_period)
    wiggle = (wiggle + 1) * 0.5 # [0,1]
    wiggle *= (angle_wiggle_left + angle_wiggle_right) # [0,l+r]
    wiggle -= angle_wiggle_left # [-l, r]
    
    rotation = angle + wiggle

func randomize_properties():
    angle_initial = rand_range(-0.3, 0.3)
    
    angle_delta_left = rand_range(0, 1.2)
    if randi()%100 < 30: angle_delta_left = 0
    
    angle_delta_right = rand_range(0, 1.2)
    if randi()%100 < 30: angle_delta_right = 0
    
    angle_speed_left = rand_range(0.1, 0.5)
    if randi()%100 < 10: angle_speed_left = rand_range(1.5, 2.0)
    
    angle_speed_right = rand_range(0.1, 0.5)
    if randi()%100 < 10: angle_speed_right = rand_range(1.5, 2.0)
    
    angle_wiggle_left = rand_range(0.2, 0.0)
    angle_wiggle_right = rand_range(0.2, 0.0)
    wiggle_period = rand_range(0.6, 2.0)
    
func get_next_seg_local_pos():
    return Vector2(0, -length)
