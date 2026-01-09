# =============================================================================
# Enemy.gd - Enemy AI controller
# =============================================================================
# This script handles enemy behavior including patrol movement, attacking,
# taking damage, and death. Enemies walk back and forth, turning at walls
# and ledges, and attack when they detect the player.
# =============================================================================
extends CharacterBody2D
class_name EnemyController

# --- Node References ---
#@onready var player: PlayerController = $"../../Player"   S                 # Reference to the player
@onready var animated_sprite_2d = $AnimatedSprite2D                         # Enemy's animated sprite
@onready var ray_cast_forward = $CollisionShape2D/RayCast_Forward           # Raycast to detect walls ahead
@onready var ray_cast_downward = $CollisionShape2D/RayCast_Downward         # Raycast to detect ledges/drops
@onready var area_2d_container = $Area2D_Container                          # Container for attack hitbox

# --- Movement Variables ---
var SPEED = 150          # Movement speed in pixels per second
var direction = -1       # Current movement direction: -1 = left, 1 = right

# --- Health & State Variables ---
@export var currentHealth = 100  # Enemy's current health (editable in Inspector)
var isDead = false               # Whether the enemy is dead
var isAttacking = false          # Whether the enemy is currently attacking

# =============================================================================
# _process(delta) - Called every frame
# Updates the enemy's animation state
# =============================================================================
func _process(_delta):
	UpdateAnimation()

# =============================================================================
# _physics_process(delta) - Called every physics frame
# Handles enemy movement, gravity, and patrol behavior
# =============================================================================
func _physics_process(_delta):
	# Apply gravity when not on the floor
	if is_on_floor() == false:
		velocity.y = 300
	
	# Don't process movement if dead
	if isDead:
		return
	
	# Handle attack state - wait for attack animation to finish
	if isAttacking:
		if animated_sprite_2d.is_playing() == false:
			isAttacking = false
		else:
			return  # Don't move while attacking
	
	# Patrol AI: Turn around if hitting a wall or reaching a ledge
	# ray_cast_forward detects walls, ray_cast_downward detects floor ahead
	if ray_cast_forward.is_colliding() || ray_cast_downward.is_colliding() == false:
		direction *= -1  # Reverse direction
		# Flip the raycasts to point in the new direction
		ray_cast_forward.target_position.x *= -1
		ray_cast_downward.target_position.x *= -1
		# Flip the attack hitbox container
		area_2d_container.scale.x = -direction
		
	# Apply horizontal movement velocity
	velocity.x = direction * SPEED
	
	# Execute the movement
	move_and_slide()

# =============================================================================
# UpdateAnimation() - Updates sprite animation based on enemy state
# Handles walk and attack animations with proper sprite flipping
# =============================================================================
func UpdateAnimation():
	# Don't update animations if dead
	if isDead:
		return
	
	# Flip sprite based on movement direction
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0
	
	# Play appropriate animation
	if isAttacking == false:
		animated_sprite_2d.play("Walk")
	elif animated_sprite_2d.animation != "Attack":
		animated_sprite_2d.play("Attack")

# =============================================================================
# ApplyDamage(damage) - Called when enemy takes damage
# Reduces health, triggers visual feedback, and handles death
# =============================================================================
func ApplyDamage(damage : int):
	# Ignore damage if already dead
	if isDead:
		return
	
	# Reduce health by damage amount
	currentHealth -= damage
	
	# Visual feedback: blink effect and camera shake
	start_blink()
	GameManager.StartCameraShake()
	
	# Check for death
	if currentHealth <= 0:
		isDead = true
		
		# Award coins to the player for killing enemy
		var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
		player.CollectedCoin(10)
		
		# Play death animation
		animated_sprite_2d.play("Die")
		
		# Disable collision so player can walk through corpse
		set_collision_layer_value(3, false)
		
		# Wait 2 seconds then remove from scene
		await get_tree().create_timer(2).timeout
		queue_free()

# =============================================================================
# UpdateBlink(newValue) - Shader parameter callback for blink effect
# Used by tween to animate the damage blink shader
# =============================================================================
func UpdateBlink(newValue:float):
	animated_sprite_2d.set_instance_shader_parameter("Blink", newValue)

# =============================================================================
# _on_area_2d_player_detector_body_entered(body) - Player detection callback
# Triggers attack when player enters the detection area
# =============================================================================
func _on_area_2d_player_detector_body_entered(_body):
	isAttacking = true

# =============================================================================
# start_blink() - Initiates the damage blink visual effect
# Creates a tween that animates the blink shader from 1.0 to 0.0
# =============================================================================
func start_blink():
	# Create a tween for smooth blink animation
	var blink_tween = get_tree().create_tween()
	# Animate from full blink (white) to no blink over 0.1 seconds
	blink_tween.tween_method(UpdateBlink, 1.0, 0.0, 0.1)
