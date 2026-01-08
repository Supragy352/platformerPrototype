# =============================================================================
# PlayerResetArea.gd - Kill zone/respawn trigger
# =============================================================================
# This script creates a death zone (e.g., pits, spikes) that resets the
# player's position when they enter it. Typically placed below platforms
# to catch falling players.
# =============================================================================
extends Area2D

# =============================================================================
# _on_body_entered(body) - Signal callback when a body enters the area
# Tells the GameManager to reset the player to their spawn point
# =============================================================================
func _on_body_entered(body):
	# Notify GameManager to respawn the player at their original position
	GameManager.PlayerEnteredResetArea()
