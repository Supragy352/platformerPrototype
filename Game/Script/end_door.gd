# =============================================================================
# end_door.gd - Level completion trigger (exit door)
# =============================================================================
# This script handles the end-of-level door behavior. When the player enters
# the door's area, it signals the GameManager to handle level completion.
# =============================================================================
extends Area2D

# =============================================================================
# _on_body_entered(body) - Signal callback when a body enters the door area
# Notifies GameManager that the player has reached the level exit
# =============================================================================
func _on_body_entered(_body: Node2D) -> void:
	# Tell the GameManager the player has entered the end door
	# This will trigger game over/level complete logic
	GameManager.PlayerEnteredEndDoor()
