extends Node2D

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	# Make sure the video is stopped initially
	video_stream_player.stop()

func _on_area_2d_body_entered(body:Node2D) -> void:
	# Check if the body that entered is the player
	if body is PlayerController:
		print("Player entered video area")
		self.visible = true
		video_stream_player.play()
		print("Video is now visible and playing")