# =============================================================================
# Player.gd - Main player controller
# =============================================================================
# This script handles all player functionality including movement, jumping,
# shooting, health/damage, coin collection, and state management.
# Uses a state machine for handling Normal, Hurt, Dead, and Uncontrollable states.
# =============================================================================
extends CharacterBody2D
class_name PlayerController

# --- Movement Constants ---
const SPEED = 190           # Horizontal movement speed in pixels per second
const JUMP_VELOCITY = -470  # Initial vertical velocity when jumping (negative = upward)
const GRAVITY = 1650        # Gravity acceleration in pixels per second squared

# --- Node References ---
@onready var animated_sprite_2d = $AnimatedSprite2D  # Player's animated sprite
@onready var shooting_point = $Shooting_Point        # Position marker for bullet spawning
@onready var playerCamera: Camera2D = $Camera2D      # Camera that follows the player

# --- State Tracking Variables ---
var AirborneLastFrame = false      # Tracks if player was in air last frame (for landing detection)
var isShooting = false             # Whether player is currently in shooting animation
const SHOOT_DURATION = 0.249       # Duration of shooting cooldown in seconds

# --- Player State Machine ---
# Defines all possible player states
enum PlayerState {Normal, Hurt, Dead, Uncontrollable}

# Current state with setter that handles state transitions
var currentState : PlayerState = PlayerState.Normal:
	set(new_value):
		currentState = new_value
		# Handle state-specific initialization
		match currentState:
			PlayerState.Hurt:
				# Play appropriate hurt animation based on grounded state
				if is_on_floor():
					animated_sprite_2d.play("Hit_Stand")
				else:
					animated_sprite_2d.play("Hit_Jump")
			PlayerState.Dead:
				# Play death animation and disable collision
				animated_sprite_2d.play("Die")
				set_collision_layer_value(2, false)  # Disable player collision layer
				GameManager.PlayerIsDead()           # Notify game manager
			PlayerState.Uncontrollable:
				# Disable collision (used for level complete)
				set_collision_layer_value(2, false)

# --- Health System ---
# Current health with setter that emits signal for UI updates
var currentHealth:
	set(new_value):
		currentHealth = new_value
		emit_signal("playerHealthUpdated",currentHealth, MAX_HEALTH)

const MAX_HEALTH = 100  # Maximum player health

# --- Stamina System ---
# Current stamina with setter that emits signal for UI updates
var currentStamina:
	set(new_value):
		currentStamina = new_value
		emit_signal("playerStaminaUpdated", currentStamina, MAX_STAMINA)

const MAX_STAMINA = 100        # Maximum player stamina
const STAMINA_REGEN_RATE = 10  # Stamina regeneration rate per second

# --- Score System ---
# Current score with setter that emits signal for UI updates
var currentScore = 0:
	set(new_value):
		currentScore = new_value
		emit_signal("playerScoreUpdated", currentScore)

# --- Coin System ---
# Current coins with setter that emits signal for UI updates
var currentCoin = 0:
	set(new_value):
		currentCoin = new_value
		emit_signal("playerCoinUpdated", currentCoin)

# --- Timer System ---
# Current timer with setter that emits signal for UI updates
var currentTimer = 0:
	set(new_value):
		currentTimer = new_value
		emit_signal("playerTimerUpdated", currentTimer)

# --- Signals for UI Communication ---
signal playerHealthUpdated(newValue, maxValue)   # Emitted when health changes
signal playerStaminaUpdated(newValue, maxValue)  # Emitted when stamina changes
signal playerScoreUpdated(newValue)              # Emitted when score changes
signal playerCoinUpdated(newValue)               # Emitted when coin count changes
signal playerTimerUpdated(newValue)              # Emitted when timer changes

# =============================================================================
# _ready() - Called when the node enters the scene tree
# Initializes player state and registers with GameManager
# =============================================================================
func _ready():
	# Set starting health & stamina to maximum
	currentHealth = MAX_HEALTH
	currentStamina = MAX_STAMINA

	# Register player with the GameManager singleton
	GameManager.player = self
	GameManager.playerOriginalPos = position           # Store spawn point for respawning
	GameManager.playerCamera = playerCamera            # Share camera reference
	GameManager.playerCameraOriginalOffset = playerCamera.offset  # Store camera offset for shake

# =============================================================================
# _process(delta) - Called every frame
# Handles animation updates
# =============================================================================
func _process(delta):
	# Update timer
	currentTimer += delta

	# Update player animation
	UpdateAnimation()

# =============================================================================
# _physics_process(delta) - Called every physics frame
# Handles movement, jumping, gravity, input, and one-way platform drop-through
# =============================================================================
func _physics_process(delta):
	# --- Gravity & Landing Detection ---
	if is_on_floor() == false:
		# Player is airborne - apply gravity
		AirborneLastFrame = true
		velocity.y += GRAVITY * delta
	elif AirborneLastFrame:
		# Player just landed - spawn landing VFX
		OnPlayerLandVFX()
		AirborneLastFrame = false

	# --- State-Based Movement Lock ---
	# Don't allow movement during hurt, dead, or uncontrollable states
	if currentState == PlayerState.Hurt || currentState == PlayerState.Dead || currentState == PlayerState.Uncontrollable:
		velocity.x = 0
		move_and_slide()
		return

	# --- Jump Input ---
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		if currentStamina >= STAMINA_REGEN_RATE * 0.5:   # Check if stamina is sufficient
			currentStamina -= STAMINA_REGEN_RATE * 0.5   # Decrease stamina for jump
			velocity.y += JUMP_VELOCITY  			     # Apply upward velocity
			OnPlayerJumpVFX()            			     # Spawn jump VFX

	# --- Horizontal Movement ---
	var direction = Input.get_axis("Left","Right")  # Get input direction (-1, 0, or 1)
	if direction != 0:
		velocity.x = direction * SPEED  # Move in input direction
	else:
		velocity.x = 0  # Stop horizontal movement when no input

		if currentStamina < 100:                         # check if stamina is below maximum
			currentStamina += STAMINA_REGEN_RATE * delta # increment stamina when idle

	# --- Shooting Input ---
	if Input.is_action_just_pressed("Shoot"):
		TryToShoot()

	# --- One-Way Platform Drop-Through ---
	# Pressing down while on floor nudges player down to fall through platforms
	if Input.is_action_just_pressed("Down") and is_on_floor():
		position.y += 3  # Move slightly down to pass through one-way collision

	# Apply movement and handle collisions
	move_and_slide()

# =============================================================================
# UpdateAnimation() - Updates player sprite animation based on current state
# Handles state transitions, sprite flipping, and animation selection
# =============================================================================
func UpdateAnimation():
	# Don't update animations while dead
	if currentState == PlayerState.Dead:
		return
	# Wait for hurt animation to finish before returning to normal
	elif currentState == PlayerState.Hurt:
		if animated_sprite_2d.is_playing():
			return
		else:
			currentState = PlayerState.Normal

	# --- Sprite Flipping ---
	# Flip sprite and shooting point based on movement direction
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0  # Flip when moving left
		# Move shooting point to correct side
		if velocity.x < 0:
			shooting_point.position.x = -26  # Left side
		else:
			shooting_point.position.x = 26   # Right side

	# --- Grounded Animations ---
	if is_on_floor():
		if abs(velocity.x) >= 0.1:
			# Player is moving - play run animation
			var playinganimationFrame = animated_sprite_2d.frame
			var playingAnimationName = animated_sprite_2d.animation

			if isShooting:
				# Play shooting while running animation
				animated_sprite_2d.play("Shoot_Run")
				# Preserve animation frame if transitioning from regular run
				if playingAnimationName == "Run":
					animated_sprite_2d.frame = playinganimationFrame
			else:
				# Let Shoot_Run finish before switching to Run
				if playingAnimationName == "Shoot_Run" && animated_sprite_2d.is_playing():
					pass  # Don't interrupt shooting animation
				else:
					animated_sprite_2d.play("Run")
		else:
			# Player is standing still
			if isShooting:
				animated_sprite_2d.play("Shoot_Stand")
			else:
				animated_sprite_2d.play("Idle")
	# --- Airborne Animations ---
	else:
		animated_sprite_2d.play("Jump")
		# Override with shooting animation if shooting in air
		if isShooting:
			animated_sprite_2d.play("Shoot_Jump")

# =============================================================================
# OnPlayerJumpVFX() - Spawns visual effect when player jumps
# =============================================================================
func OnPlayerJumpVFX():
	var vfxToSpawn = preload("res://Game/Scene/vfx_jump_up.tscn")
	GameManager.SpawnVFX(vfxToSpawn, global_position)

# =============================================================================
# OnPlayerLandVFX() - Spawns visual effect when player lands
# =============================================================================
func OnPlayerLandVFX():
	var vfxToSpawn = preload("res://Game/Scene/vfx_land.tscn")
	GameManager.SpawnVFX(vfxToSpawn, global_position)

# =============================================================================
# Shoot() - Creates and fires a bullet projectile
# Spawns bullet at shooting point and sets direction based on player facing
# =============================================================================
func Shoot():
	# Load and spawn bullet at shooting point
	var bulletToSpawn = preload("res://Game/Scene/bullet.tscn")
	var bulletInstance = GameManager.SpawnVFX(bulletToSpawn, shooting_point.global_position)

	# Shooting would decrease some stamina
	currentStamina -= STAMINA_REGEN_RATE * 1.5

	# Set bullet direction based on which way player is facing
	if animated_sprite_2d.flip_h:
		bulletInstance.direction = -1  # Shoot left
	else:
		bulletInstance.direction = 1   # Shoot right

# =============================================================================
# TryToShoot() - Attempts to fire a bullet with cooldown management
# Prevents shooting while already shooting (cooldown active)
# =============================================================================
func TryToShoot():
	# Don't shoot if already shooting (cooldown active)
	if isShooting or currentStamina < 15:
		return

	# Set shooting state and fire
	isShooting = true
	Shoot()
	PlayFireVFX()

	# Wait for cooldown duration before allowing another shot
	await get_tree().create_timer(SHOOT_DURATION).timeout
	isShooting = false

# =============================================================================
# PlayFireVFX() - Spawns muzzle flash visual effect when shooting
# =============================================================================
func PlayFireVFX():
	# Load and spawn muzzle flash at shooting point
	var vfxToSpawm = preload("res://Game/Scene/vfx_player_fire.tscn")
	var vfxInstance = GameManager.SpawnVFX(vfxToSpawm, shooting_point.global_position)

	# Flip VFX to match player facing direction
	if animated_sprite_2d.flip_h:
		vfxInstance.scale.x = -1

# =============================================================================
# ApplyDmage(damage) - Called when player takes damage from enemies
# Reduces health, triggers hurt state, and handles death
# =============================================================================
func ApplyDmage(damage:int):
	# Ignore damage during hurt invincibility or when dead
	if currentState == PlayerState.Hurt || currentState == PlayerState.Dead:
		return

	# Apply damage and enter hurt state
	currentHealth -= damage
	currentState = PlayerState.Hurt

	# Check for death
	if currentHealth <= 0:
		currentHealth = 0
		currentState = PlayerState.Dead

# =============================================================================
# KilledEnemy(value) - Called when player kills an enemy
# Adds to score count and heals the player based on enemy value
# =============================================================================
func KilledEnemy(value:int):
	# Add coin value to total
	currentScore += value

	# Heal player (30 HP per kill value) up to max health
	if currentHealth < MAX_HEALTH:
		currentHealth += 3 * value
		# Cap health at maximum
		if currentHealth > MAX_HEALTH:
			currentHealth = MAX_HEALTH

# =============================================================================
# CollectedCoin(value) - Called when player collects a coin
# Adds to coin count and heals the player based on coin value
# =============================================================================
func CollectedCoin(value:int):
	# Add coin value to total
	currentCoin += value

	# Heal player (3 HP per coin value) up to max health
	if currentHealth < MAX_HEALTH:
		currentHealth += 3 * value
		# Cap health at maximum
		if currentHealth > MAX_HEALTH:
			currentHealth = MAX_HEALTH

# =============================================================================
# SwitchStateToUncontrollable() - Disables player control
# Used when reaching level exit or for cutscenes
# =============================================================================
func SwitchStateToUncontrollable():
	currentState = PlayerState.Uncontrollable
