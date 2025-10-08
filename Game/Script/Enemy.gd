extends CharacterBody2D
class_name EnemyController
@onready var player: PlayerController = $"../../Player"

var SPEED = 150
var direction = -1
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_forward = $CollisionShape2D/RayCast_Forward
@onready var ray_cast_downward = $CollisionShape2D/RayCast_Downward
@onready var area_2d_container = $Area2D_Container

@export var currentHealth = 100
var isDead = false
var isAttacking = false

func _process(delta):
	UpdateAnimation()

func _physics_process(delta):
	if is_on_floor() == false:
		velocity.y = 300
	
	if isDead:
		return
	
	if isAttacking:
		if animated_sprite_2d.is_playing() == false:
			isAttacking = false
		else:
			return
	
	if ray_cast_forward.is_colliding() || ray_cast_downward.is_colliding() == false:
		direction *= -1
		ray_cast_forward.target_position.x *= -1
		ray_cast_downward.target_position.x *= -1
		area_2d_container.scale.x = -direction
		
	velocity.x = direction * SPEED
	
	move_and_slide()
	
func UpdateAnimation():
	if isDead:
		return
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0
	if isAttacking == false:
		animated_sprite_2d.play("Walk")
	elif animated_sprite_2d.animation != "Attack":
		animated_sprite_2d.play("Attack")
			
func ApplyDamage(damage : int):
	if isDead:
		return
	currentHealth -= damage
	start_blink()
	GameManager.StartCameraShake()
	
	if currentHealth <= 0:
		isDead = true
		var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
		player.CollectedCoin(10)
		animated_sprite_2d.play("Die")
		set_collision_layer_value(3, false)
		await get_tree().create_timer(2).timeout
		queue_free()

func UpdateBlink(newValue:float):
	animated_sprite_2d.set_instance_shader_parameter("Blink", newValue)

func _on_area_2d_player_detector_body_entered(body):
	isAttacking = true

func start_blink():
	var blink_tween = get_tree().create_tween()
	blink_tween.tween_method(UpdateBlink, 1.0, 0.0, 0.1)
