extends Node2D

############################################
# CONSTS
const HEALTH_PER_SEG = 1.0

############################################
# CUSTOMIZATION

export(float) var angle_initial = 0.0

export(float) var angle_speed_left = 0.7
export(float) var angle_speed_right = 0.7
export(float) var angle_delta_left = 0.0
export(float) var angle_delta_right = 0.0

export(float) var min_length = 42
export(float) var max_length = 42
export(float) var extend_contract_speed = 20

export(float) var angle_wiggle_left = 0.0
export(float) var angle_wiggle_right = 0.0
export(float) var wiggle_period = 1.0

export(float) var width = 10
export(float) var length_initial = 42



############################################
# NODES

onready var line = $Visual/Line
onready var circle = $Visual/Circle
onready var sprite = $Visual/Sprite
onready var spriteEmpty = $Visual/SpriteEmpty

############################################
# STATE

var show_start_anim = false
var start_anim_done = false
var giraffe
var angle = 0
var length = length_initial

############################################
# RANDOM KEY MAPPING
enum Action {
    Left, Right, Extend, Contract
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
    keys.erase(key)
    keys.erase(antagonist_keys[key])
    key_to_action_map[key] = Action.Left
    key_to_action_map[antagonist_keys[key]] = Action.Right
    
    key = keys[randi()%keys.size()]
    key_to_action_map[key] = Action.Extend
    key_to_action_map[antagonist_keys[key]] = Action.Contract
    
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
    
    sprite.scale.x = width / float(sprite.texture.get_width())
    spriteEmpty.scale.x = sprite.scale.x
    
    line.rect_size.x = width
    line.rect_position.x = -width/2
    
    var s = width / float(circle.texture.get_width())
    circle.scale = Vector2(s, s)
    circle.position.x = 0
    
    if show_start_anim:
        $Tween.connect("tween_all_completed", self, "_on_start_anim_done")
        $Tween.interpolate_method(self, "set_length", 0, length_initial, 1.8, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
        $Tween.start()
    else:
        set_length(length_initial)
        
    
    var h = sprite.texture.get_height()
    sprite.region_rect = Rect2(0, 0, sprite.texture.get_width(), h)
    sprite.position.y = spriteEmpty.position.y
    sprite.region_enabled = true
        
func set_health(health):
    var my_health = min(HEALTH_PER_SEG, health)
    
    var rel_health = (my_health / HEALTH_PER_SEG)
    var h = sprite.texture.get_height() * rel_health
    sprite.region_rect = Rect2(0, 0, sprite.texture.get_width(), h)
    
    sprite.position.y = spriteEmpty.position.y + (1 - my_health / HEALTH_PER_SEG) * sprite.texture.get_height() * sprite.scale.y * 0.5
    
    for child in get_children():
        if child.is_in_group("Seg"):
            child.set_health(health - my_health)

func _on_start_anim_done():
    start_anim_done = true
    
func set_length(new_length):
    length = new_length
    line.rect_size.y = length
    line.rect_position.y = -length
    circle.position.y = -length
    
    sprite.scale.y = length / float(sprite.texture.get_height())
    sprite.position.y = -length * 0.5
    
    spriteEmpty.scale.y = sprite.scale.y
    spriteEmpty.position.y = sprite.position.y
    
    for child in get_children():
        if child.is_in_group("Head") or child.is_in_group("Seg"):
            child.position = get_next_seg_local_pos()


var is_dead = false
var death_angle_speed
func dead():
    is_dead = true
    death_angle_speed = rand_range(-1.8, 1.8)

func _process(delta):    
    if is_dead:
        rotation += delta * death_angle_speed
        set_length(length *0.98)
        return
        
    var actions = []
    for key in key_to_action_map.keys():
        if Input.is_action_pressed(key):
            actions.append(key_to_action_map[key])
    
    if actions.has(Action.Left):
        angle -= angle_speed_left * delta
    if actions.has(Action.Right):
        angle += angle_speed_right * delta
    var last_length = length
    if actions.has(Action.Contract):
        length -= extend_contract_speed * delta
    if actions.has(Action.Extend):
        length += extend_contract_speed * delta

    angle = clamp(angle, angle_initial - angle_delta_left, angle_initial + angle_delta_right)
    length = clamp(length, min_length, max_length)
    
    if (!show_start_anim or start_anim_done) and last_length != length:
        set_length(length)
    
    
    var wiggle = sin((2*PI) * giraffe.time / wiggle_period)
    wiggle = (wiggle + 1) * 0.5 # [0,1]
    wiggle *= (angle_wiggle_left + angle_wiggle_right) # [0,l+r]
    wiggle -= angle_wiggle_left # [-l, r]
    
    rotation = angle + wiggle

func randomize_properties():
    angle_initial = rand_range(-0.3, 0.3)
    
    var r = randi() % 10
    
    # NORMAL ANGLE
    if r >= 0 and r <= 6:
        angle_delta_left = rand_range(1.0, 2.2)
        angle_delta_right = rand_range(1.0, 2.2)
        angle_speed_left = rand_range(0.4, 0.7)
        angle_speed_right = rand_range(0.4, 0.7)
    # CRAZY ANGLE
    if r == 7:
        angle_delta_left = rand_range(PI, 2*PI)
        angle_delta_right = rand_range(PI, 2*PI)
        angle_speed_left = rand_range(0.8, 1.5)
        angle_speed_right = rand_range(0.8, 1.5)
    # EXTEND, CONTRACT
    if r >= 8 and r <= 9:
        min_length = rand_range(length-25, length-15)
        max_length = rand_range(length+15, length+25)
        extend_contract_speed = rand_range(30, 60)
    
    angle_wiggle_left = rand_range(0.05, 0.1)
    angle_wiggle_right = rand_range(0.05, 0.1)
    wiggle_period = rand_range(0.6, 2.0)
    
func get_next_seg_local_pos():
    return Vector2(0, -length)
    

var stored_rotation
var stored_length
func set_angle_random():
    var a_min = angle_initial - angle_delta_left
    var a_max = angle_initial + angle_delta_right
    
    stored_rotation = rotation
    rotation = a_min + (a_max - a_min) * randf()
    
    stored_length = length
    set_length(min_length + (max_length - min_length) * randf())

func restore_angle():
    rotation = stored_rotation
    set_length(stored_length)
