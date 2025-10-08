extends Node2D
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.play("Start")

func _process(delta):
	if animated_sprite_2d.is_playing() == false:
		queue_free()
