# =============================================================================
# EnemyDamageCaster.gd - Enemy attack hitbox controller
# =============================================================================
# This script manages the enemy's damage hitbox during attack animations.
# It only activates the hitbox during specific frames of the attack animation
# to create precise timing for when attacks can hit the player.
# =============================================================================
extends Area2D

# --- Node References ---
@onready var animated_sprite_2d = $"../../AnimatedSprite2D"  # Reference to enemy's animated sprite
@onready var collision_shape_2d = $CollisionShape2D          # The hitbox collision shape

# --- Constants ---
const START_FRAME = 10  # First frame where the attack can deal damage
const END_FRAME = 13    # Last frame where the attack can deal damage
const DAMAGE = 30       # Amount of damage dealt to the player

# =============================================================================
# _process(delta) - Called every frame
# Enables/disables the hitbox based on current animation frame
# Only the "active" frames of the attack animation can deal damage
# =============================================================================
func _process(delta):
	# Check if enemy is playing the Attack animation
	if animated_sprite_2d.animation == "Attack":
		# Enable hitbox only during the damage frames (frames 10-13)
		if animated_sprite_2d.frame >= START_FRAME && animated_sprite_2d.frame <= END_FRAME:
			monitoring = true                  # Enable collision detection
			collision_shape_2d.visible = true  # Show hitbox (for debugging)
			return
	
	# Disable hitbox when not in damage frames or not attacking
	monitoring = false
	collision_shape_2d.visible = false

# =============================================================================
# _on_body_entered(body) - Signal callback when hitbox touches a body
# Applies damage to the player if they are hit during active frames
# =============================================================================
func _on_body_entered(body):
	# Check if the body is the player
	var player = body as PlayerController
	if player:
		# Deal damage to the player
		player.ApplyDmage(DAMAGE)
