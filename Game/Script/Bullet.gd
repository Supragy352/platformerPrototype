extends Area2D
const SPEED = 500
var direction = 1
const DAMAGE = 35

@onready var bullet_sprite_2d = $Bullet_Sprite2D

func _physics_process(delta):
	if direction == -1:
		bullet_sprite_2d.flip_h = true

	position.x += SPEED * direction * delta

func _on_body_entered(body):
	var vfxToSpawn = preload("res://Game/Scene/vfx_bullet_hit.tscn")
	var vfxInstance = GameManager.SpawnVFX(vfxToSpawn, global_position)

	if direction == -1:
		vfxInstance.scale.x = -1

	var enemy = body as EnemyController
	if enemy:
		enemy.ApplyDamage(DAMAGE)

	queue_free()
