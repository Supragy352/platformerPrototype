# =============================================================================
# CutsceneTrigger.gd - Trigger zone for playing video cutscenes
# =============================================================================
# This script creates a trigger area that plays a video cutscene when the
# player enters it. The game pauses during playback and resumes when the
# cutscene finishes or the player exits the trigger area.
# =============================================================================
extends Area2D

# --- Node References ---
# Reference to the VideoStreamPlayer node for cutscene playback
@onready var cutscene = $"../CutscenePlayer/VideoStreamPlayer"

# =============================================================================
# _ready() - Called when the node enters the scene tree
# Sets up signal connections for cutscene completion
# =============================================================================
func _ready():
	# Connect the finished signal from the VideoStreamPlayer to handle end of cutscene
	cutscene.finished.connect(_on_cutscene_player_finished)

# =============================================================================
# _on_body_entered(body) - Signal callback when a body enters the trigger area
# Starts cutscene playback and pauses the game
# =============================================================================
func _on_body_entered(body):
	# Only trigger for bodies in the "player" group
	if body.is_in_group("player"):
		# Make the cutscene visible and start playing
		cutscene.visible = true
		cutscene.play()
		
		# Pause the game tree so gameplay stops during cutscene
		get_tree().paused = true
		
		# In Godot 4, pause_mode has been replaced with process_mode
		# PROCESS_MODE_ALWAYS ensures the video continues playing even when game is paused
		cutscene.process_mode = Node.PROCESS_MODE_ALWAYS

# =============================================================================
# _on_body_exited(body) - Signal callback when a body exits the trigger area
# Stops the cutscene and resumes gameplay if player leaves early
# =============================================================================
func _on_body_exited(body):
	# Only handle player exiting
	if body.is_in_group("player"):
		# Stop and hide the cutscene
		cutscene.stop()
		cutscene.visible = false
		
		# Resume gameplay
		get_tree().paused = false

# =============================================================================
# _on_cutscene_player_finished() - Signal callback when cutscene ends naturally
# Cleans up cutscene state and resumes gameplay
# =============================================================================
func _on_cutscene_player_finished():
	# Hide the cutscene video
	cutscene.visible = false
	
	# Resume gameplay
	get_tree().paused = false
