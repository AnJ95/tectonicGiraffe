extends Node2D

func _ready():
    $AnimationPlayer.play("wiggle")

func _on_TextureButton_pressed():
    get_tree().change_scene("res://main/Main.tscn")
