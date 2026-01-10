# =============================================================================
# Coin.gd - Collectible coin controller
# =============================================================================
# This script handles coin collection behavior. When the player touches a coin,
# it plays a collection animation, adds value to the player's coin count,
# and then removes itself from the scene.
# =============================================================================
extends Area2D

# --- Node References ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D  # Reference to coin's animated sprite

# --- Exported Variables (editable in Inspector) ---
@export var value = 5  # The coin value added to player's total when collected

# =============================================================================
# _on_body_entered(body) - Signal callback when a body enters the coin's area
# Triggers collection animation and awards coins to the player
# =============================================================================
func _on_body_entered(body: Node2D):	
	# Play the "collected" animation (coin pickup effect)
	animated_sprite_2d.play("collected")
	
	# Check if the colliding body is the player
	var player = body as PlayerController
	if player:
		# Award the coin value to the player
		player.CollectedCoin(value)

# =============================================================================
# _process(delta) - Called every frame
# Monitors animation state and removes coin when collection animation finishes
# =============================================================================
func _process(_delta: float):
	# Once the collection animation has finished, remove the coin from scene
	if animated_sprite_2d.is_playing() == false:
		queue_free()
