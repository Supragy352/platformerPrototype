extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var value = 5

func _on_body_entered(body: Node2D):	
	animated_sprite_2d.play("collected")
	var player = body as PlayerController
	if player:
		player.CollectedCoin(value)

func _process(delta: float):
	if animated_sprite_2d.is_playing() == false:
		queue_free()
