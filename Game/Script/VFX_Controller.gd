# =============================================================================
# VFX_Controller.gd - Visual effects lifecycle controller
# =============================================================================
# This script manages one-shot visual effects (particles, explosions, etc.).
# It automatically plays the "Start" animation when spawned and removes
# itself from the scene when the animation completes.
# =============================================================================
extends Node2D

# --- Node References ---
@onready var animated_sprite_2d = $AnimatedSprite2D  # The animated sprite for the VFX

# =============================================================================
# _ready() - Called when the node enters the scene tree
# Immediately starts playing the VFX animation
# =============================================================================
func _ready():
	# Play the "Start" animation (the main VFX animation)
	animated_sprite_2d.play("Start")

# =============================================================================
# _process(delta) - Called every frame
# Monitors animation state and cleans up when finished
# =============================================================================
func _process(_delta):
	# Remove the VFX node once the animation has finished playing
	if animated_sprite_2d.is_playing() == false:
		queue_free()
