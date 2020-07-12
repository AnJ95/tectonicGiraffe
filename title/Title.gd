extends Node2D

func _ready():
    $AnimationPlayer.play("wiggle")

func _on_TextureButton_pressed():
    $Particles2D.emitting = true
    $Timer.start()

func _on_Timer_timeout():
    get_tree().change_scene("res://main/Main.tscn")
