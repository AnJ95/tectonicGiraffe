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
export(float) var length = 50



############################################
# NODES

onready var line = $Visual/Line
onready var circle = $Visual/Circle

############################################
# STATE

var show_start_anim = false
var giraffe
var angle = 0

############################################
# RANDOM KEY MAPPING
enum Action {
    Left, Right
}
var keys = ["key_0", "key_1", "key_2", "key_3"]
var antagonist_keys = {
    "key_0" : "key_3",
    "key_3" : "key_0",
    "key_1" : "key_2",
    "key_2" : "key_1"
}
var actions = [Action.Left, Action.Right]

var key_to_action_map = {}

func init_key_mapping():
    # Var 1:
#    while actions.size() > 0 and keys.size() > 0:
#        var key = keys[randi()%keys.size()]
#        var action = actions[randi()%actions.size()]
#        key_to_action_map[key] = action
#        print(str(key) + " => " + str(action))
#        keys.erase(key)
#        actions.erase(action)

    var key = keys[randi()%keys.size()]
    key_to_action_map[key] = Action.Left
    key_to_action_map[antagonist_keys[key]] = Action.Right
############################################
# LIFE CYCLE
func init(giraffe, show_start_anim=false):
    self.giraffe = giraffe
    self.show_start_anim = show_start_anim
    return self
    
func _ready():
    init_key_mapping()
    
    randomize_properties()
    
    var par = get_parent()
    if par and par.is_in_group("Seg"):
        position = par.get_next_seg_local_pos()
    
    angle = angle_initial
    rotation = angle
    
    line.rect_size.x = width
    line.rect_position.x = -width/2
    
    var s = width / float(circle.texture.get_width())
    circle.scale = Vector2(s, s)
    circle.position.x = 0
    
    if show_start_anim:
        print("1")
        $Tween.interpolate_method(self, "set_length", 0, length, 1.0, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
        $Tween.start()
    else:
        print("2")
        set_length(length)

func set_length(new_length):
    length = new_length
    line.rect_size.y = length
    line.rect_position.y = -length
    circle.position.y = -length
    for child in get_children():
        if child.is_in_group("Head") or child.is_in_group("Seg"):
            child.position = get_next_seg_local_pos()
    

func _process(delta):    
    var actions = []
    for key in key_to_action_map.keys():
        if Input.is_action_pressed(key):
            actions.append(key_to_action_map[key])
    
    if actions.has(Action.Left):
        angle -= angle_speed_left * delta
    if actions.has(Action.Right):
        angle += angle_speed_right * delta

    angle = clamp(angle, angle_initial - angle_delta_left, angle_initial + angle_delta_right)
    
    
    var wiggle = sin((2*PI) * giraffe.time / wiggle_period)
    wiggle = (wiggle + 1) * 0.5 # [0,1]
    wiggle *= (angle_wiggle_left + angle_wiggle_right) # [0,l+r]
    wiggle -= angle_wiggle_left # [-l, r]
    
    rotation = angle + wiggle

func randomize_properties():
    angle_initial = rand_range(-0.3, 0.3)
    
    angle_delta_left = rand_range(1.0, 2.2)
    if randi()%100 < 20: angle_delta_left = 0
    
    angle_delta_right = rand_range(1.0, 2.2)
    if randi()%100 < 20: angle_delta_right = 0
    
    angle_speed_left = rand_range(0.25, 0.5)
    if randi()%100 < 10: angle_speed_left = rand_range(1.5, 2.0)
    
    angle_speed_right = rand_range(0.25, 0.5)
    if randi()%100 < 10: angle_speed_right = rand_range(1.5, 2.0)
    
    angle_wiggle_left = rand_range(0.1, 0.15)
    angle_wiggle_right = rand_range(0.1, 0.15)
    wiggle_period = rand_range(0.6, 2.0)
    
func get_next_seg_local_pos():
    return Vector2(0, -length)
    

var stored_rotation
func set_angle_random():
    var a_min = angle_initial - angle_delta_left
    var a_max = angle_initial + angle_delta_right
    
    stored_rotation = rotation
    rotation = a_min + (a_max - a_min) * randf()

func restore_angle():
    rotation = stored_rotation
