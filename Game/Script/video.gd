# =============================================================================
# video.gd - Video playback trigger controller
# =============================================================================
# This script manages a video that plays when the player enters a trigger area.
# The video starts hidden and stopped, then becomes visible and plays when
# the player enters the associated Area2D trigger zone.
# =============================================================================
extends Node2D

# --- Node References ---
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer  # Video player node

# =============================================================================
# _ready() - Called when the node enters the scene tree
# Ensures the video is stopped and ready to be triggered
# =============================================================================
func _ready() -> void:
	# Make sure the video is stopped initially (not auto-playing)
	video_stream_player.stop()

# =============================================================================
# _on_area_2d_body_entered(body) - Signal callback for trigger area
# Starts video playback when the player enters the trigger zone
# =============================================================================
func _on_area_2d_body_entered(body:Node2D) -> void:
	# Check if the body that entered is the player
	if body is PlayerController:
		print("Player entered video area")  # Debug message
		
		# Make the video visible and start playing
		self.visible = true
		video_stream_player.play()
		
		print("Video is now visible and playing")  # Debug message