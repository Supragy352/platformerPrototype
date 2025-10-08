extends Node

var player : PlayerController
var playerOriginalPos
var cameraShakeNoise : FastNoiseLite
var playerCameraOriginalOffset: Vector2
var playerCamera : Camera2D
signal GameOver()

func _ready() -> void:
	cameraShakeNoise = FastNoiseLite.new()

func PlayerEnteredResetArea():
	player.position = playerOriginalPos

func SpawnVFX(vfxToSpawn : Resource, position : Vector2):
	var vfxInstance = vfxToSpawn.instantiate()
	vfxInstance.global_position = position
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	
	return vfxInstance
	
func PlayerIsDead():
	emit_signal("GameOver")
	
func PlayerEnteredEndDoor():
	player.SwitchStateToUncontrollable()
	emit_signal("GameOver")

func StartCameraShake():
	var cameraShakeTween = get_tree().create_tween()
	cameraShakeTween.tween_method(UpdateCameraShake, 2.0, 0.0, 0.5)
	
func UpdateCameraShake(intensity: float):
	var cameraOffset = cameraShakeNoise.get_noise_1d(Time.get_ticks_msec()) * intensity * 5
	playerCamera.offset.x = playerCameraOriginalOffset.x + cameraOffset
	playerCamera.offset.y = playerCameraOriginalOffset.y + cameraOffset
