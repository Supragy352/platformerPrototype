# =============================================================================
# GameManager.gd - Global game state manager (Autoload/Singleton)
# =============================================================================
# This script acts as a central hub for game-wide functionality including:
# - Player reference and spawn point management
# - VFX spawning utility function
# - Camera shake effects
# - Game state signals (Game Over, Level Complete)
# This should be set up as an Autoload in Project Settings.
# =============================================================================
extends Node

# --- Player References ---
var player : PlayerController             # Reference to the player controller
var playerOriginalPos                     # Player's starting position for respawning
var playerCamera : Camera2D               # Reference to the player's camera
var playerCameraOriginalOffset: Vector2   # Camera's original offset for shake reset

# --- Camera Shake ---
var cameraShakeNoise : FastNoiseLite      # Noise generator for organic camera shake

# --- Signals ---
signal GameOver()  # Emitted when the game ends (player death or level complete)

# =============================================================================
# _ready() - Called when the node enters the scene tree
# Initializes the noise generator for camera shake
# =============================================================================
func _ready() -> void:
	# Create a new noise generator for camera shake randomization
	cameraShakeNoise = FastNoiseLite.new()

# =============================================================================
# PlayerEnteredResetArea() - Called when player enters a reset/death zone
# Teleports the player back to their original spawn position
# =============================================================================
func PlayerEnteredResetArea():
	player.position = playerOriginalPos

# =============================================================================
# SpawnVFX(vfxToSpawn, position) - Utility function to spawn visual effects
# Instantiates a VFX scene at the specified position and adds it to the scene
# Returns the spawned VFX instance for further modification if needed
# =============================================================================
func SpawnVFX(vfxToSpawn : Resource, position : Vector2):
	# Create an instance of the VFX scene
	var vfxInstance = vfxToSpawn.instantiate()
	
	# Position it at the specified location
	vfxInstance.global_position = position
	
	# Add it to the Root node of the scene
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	
	# Return the instance so caller can modify it if needed
	return vfxInstance

# =============================================================================
# PlayerIsDead() - Called when the player dies
# Emits the GameOver signal to trigger game over UI
# =============================================================================
func PlayerIsDead():
	emit_signal("GameOver")

# =============================================================================
# PlayerEnteredEndDoor() - Called when player reaches the level exit
# Disables player control and triggers game over (level complete)
# =============================================================================
func PlayerEnteredEndDoor():
	# Make player uncontrollable (victory state)
	player.SwitchStateToUncontrollable()
	
	# Emit game over signal (used for both death and level complete)
	emit_signal("GameOver")

# =============================================================================
# StartCameraShake() - Initiates a camera shake effect
# Creates a tween that gradually reduces shake intensity over 0.5 seconds
# =============================================================================
func StartCameraShake():
	# Create a tween for smooth shake falloff
	var cameraShakeTween = get_tree().create_tween()
	# Animate shake intensity from 2.0 to 0.0 over 0.5 seconds
	cameraShakeTween.tween_method(UpdateCameraShake, 2.0, 0.0, 0.5)

# =============================================================================
# UpdateCameraShake(intensity) - Updates camera offset for shake effect
# Called by the shake tween to apply noise-based camera offset
# =============================================================================
func UpdateCameraShake(intensity: float):
	# Generate organic shake using noise (based on time for smooth variation)
	var cameraOffset = cameraShakeNoise.get_noise_1d(Time.get_ticks_msec()) * intensity * 5
	
	# Apply offset to both X and Y axes, adding to original offset
	playerCamera.offset.x = playerCameraOriginalOffset.x + cameraOffset
	playerCamera.offset.y = playerCameraOriginalOffset.y + cameraOffset
