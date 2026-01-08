# =============================================================================
# Bullet.gd - Projectile controller for player-fired bullets
# =============================================================================
# This script handles bullet movement, collision detection, and damage dealing.
# Bullets travel horizontally and destroy themselves upon hitting any body.
# =============================================================================
extends Area2D

# --- Constants ---
const SPEED = 500        # Movement speed of the bullet in pixels per second
const DAMAGE = 35        # Amount of damage dealt to enemies on hit

# --- Variables ---
var direction = 1        # Direction of travel: 1 = right, -1 = left

# --- Node References ---
@onready var bullet_sprite_2d = $Bullet_Sprite2D  # Reference to the bullet's sprite

# =============================================================================
# _physics_process(delta) - Called every physics frame
# Handles bullet movement and sprite orientation based on direction
# =============================================================================
func _physics_process(delta):
	# Flip the sprite horizontally if bullet is moving left
	if direction == -1:
		bullet_sprite_2d.flip_h = true

	# Move the bullet in the current direction
	position.x += SPEED * direction * delta

# =============================================================================
# _on_body_entered(body) - Signal callback when bullet collides with a body
# Spawns hit VFX, applies damage to enemies, and destroys the bullet
# =============================================================================
func _on_body_entered(body):
	# Load and spawn the bullet hit visual effect at current position
	var vfxToSpawn = preload("res://Game/Scene/vfx_bullet_hit.tscn")
	var vfxInstance = GameManager.SpawnVFX(vfxToSpawn, global_position)

	# Flip the VFX if bullet was traveling left
	if direction == -1:
		vfxInstance.scale.x = -1

	# Check if the hit body is an enemy and apply damage
	var enemy = body as EnemyController
	if enemy:
		enemy.ApplyDamage(DAMAGE)

	# Remove the bullet from the scene
	queue_free()
