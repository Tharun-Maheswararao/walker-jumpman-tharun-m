extends CharacterBody2D

## SPROCKET — a wind-up tin automaton.
##
## Replaces the starter's flat blue-visor rectangle. Physics, tuning and the
## collider are untouched; only _draw() changed. The silhouette reads as a
## clockwork toy: a chamfered brass barrel, a narrow domed head with a single
## round lens, piston legs that retract in the air, and a winding key on the
## back whose prongs turn while running and freeze while airborne.
##
## Collider contract (unchanged from the starter): an 18x28 box offset to
## (0, -14), so relative to `position` (the feet) it spans x -9..9, y -28..0.
## Every part of the body is drawn inside that box. The winding key is the one
## deliberate exception and is defined by the two constants below so a test can
## assert the overhang instead of taking this comment's word for it. The key is
## always drawn on the trailing side, so it can never be the part of the art
## that appears to touch something the player is moving toward.
const KEY_HUB_X := 8.0
const KEY_ARM := 4.5
const COLLIDER_SIZE := Vector2(18, 28)
const COLLIDER_OFFSET := Vector2(0, -14)
## How far the key reaches past the collider's side wall, in pixels.
const KEY_OVERHANG_PX := KEY_HUB_X + KEY_ARM - COLLIDER_SIZE.x / 2.0
## Topmost pixel of the drawn body, relative to the feet. Must stay >= -28.
const BODY_TOP_Y := -27.5

const Tuning = preload("res://features/player/tuning.gd")
var tuning = Tuning.new()
var enabled: bool = false
var tick: int = 0
var last_floor_tick: int = -1000
var jump_request_tick: int = -1000
var opportunity_consumed: bool = false
var require_jump_release: bool = true
var facing: float = 1.0
var jumps: int = 0
var test_control: bool = false
var test_axis: float = 0.0
var test_jump_pressed: bool = false
var test_jump_held: bool = false

func _ready() -> void:
	name = "Player"
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 1.0
	var shape := RectangleShape2D.new()
	shape.size = COLLIDER_SIZE
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = COLLIDER_OFFSET
	add_child(collider)

func reset_at(spawn: Vector2) -> void:
	position = spawn
	velocity = Vector2.ZERO
	last_floor_tick = -1000
	jump_request_tick = -1000
	opportunity_consumed = false
	require_jump_release = true
	test_jump_pressed = false
	jumps = 0
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	tick += 1
	var axis := test_axis if test_control else Input.get_axis("move_left", "move_right")
	var held := test_jump_held if test_control else Input.is_action_pressed("jump")
	var pressed := test_jump_pressed if test_control else Input.is_action_just_pressed("jump")
	test_jump_pressed = false
	if not held:
		require_jump_release = false
	if is_on_floor() and velocity.y >= 0.0:
		last_floor_tick = tick
		opportunity_consumed = false
	if pressed and not require_jump_release:
		jump_request_tick = tick
	var rate: float = tuning.acceleration if not is_zero_approx(axis) else tuning.deceleration
	velocity.x = move_toward(velocity.x, axis * tuning.speed, rate * delta)
	if not is_zero_approx(axis):
		facing = signf(axis)
	velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.terminal_velocity)
	if not opportunity_consumed and tick - last_floor_tick <= tuning.coyote_ticks and tick - jump_request_tick <= tuning.buffer_ticks:
		velocity.y = tuning.jump_velocity
		opportunity_consumed = true
		jump_request_tick = -1000
		jumps += 1
	move_and_slide()
	position.x = maxf(position.x, 10.0)
	queue_redraw()

func _draw() -> void:
	# All art is original Godot vector drawing. No imported or recovered assets.
	var casing := Color("2b2118")      # stamped-tin outline and shadow
	var brass := Color("c0873c")       # main plating
	var brass_dark := Color("8a5f27")  # recessed plates, key, hip band
	var tin := Color("ecc684")         # struck highlight
	var lens := Color("3fa392")        # the single eye lens
	var glint := Color("d9f2ec")       # lens catchlight

	var grounded := is_on_floor()
	var running: bool = grounded and absf(velocity.x) > 8.0
	var stride: float = sin(float(tick) * 0.7) * 2.0 if running else 0.0
	var f: float = facing              # +1 facing right, -1 facing left
	var back: float = -f               # the key always trails the direction of travel

	# --- winding key, on the back plate -------------------------------------
	# Prongs turn while running and hold still in the air, so "wound up and
	# driving" versus "airborne" is legible from the silhouette alone.
	var hub := Vector2(back * KEY_HUB_X, -17.0)
	draw_line(Vector2(back * 3.0, -17.0), hub, brass_dark, 3.0)
	var spin: float = float(tick) * 0.38 if running else 0.0
	for i in range(2):
		var a: float = spin + float(i) * PI * 0.5
		var arm := Vector2(cos(a), sin(a)) * KEY_ARM
		draw_line(hub - arm, hub + arm, brass_dark, 2.5)
	draw_circle(hub, 2.2, tin)
	draw_circle(hub, 1.0, casing)

	# --- piston legs ---------------------------------------------------------
	# Grounded they alternate; airborne they retract into the housing so the
	# jumping pose is distinguishable from the standing pose at a glance.
	if grounded:
		var l_len: float = 7.0 + stride
		var r_len: float = 7.0 - stride
		draw_rect(Rect2(-6.0, -8.0, 4.0, l_len), casing)
		draw_rect(Rect2(2.0, -8.0, 4.0, r_len), casing)
		draw_rect(Rect2(-7.0, -8.0 + l_len - 1.5, 6.0, 1.5), brass_dark)
		draw_rect(Rect2(1.0, -8.0 + r_len - 1.5, 6.0, 1.5), brass_dark)
	else:
		# Airborne: the pistons pull up into the housing and the foot pads splay
		# outward, so the bottom of the silhouette changes shape rather than just
		# getting shorter. Standing and jumping are told apart at a glance.
		var coil := Vector2(0, -8.0)
		for i in range(3):
			draw_line(coil + Vector2(-4.5, float(i) * 1.6), coil + Vector2(4.5, float(i) * 1.6 + 0.8), brass_dark, 1.1)
		draw_rect(Rect2(-6.5, -4.0, 4.0, 3.0), casing)
		draw_rect(Rect2(2.5, -4.0, 4.0, 3.0), casing)
		draw_colored_polygon(PackedVector2Array([
			Vector2(-8.5, -1.4), Vector2(-2.0, -2.2), Vector2(-2.0, -0.4), Vector2(-8.0, 0.0)]), brass_dark)
		draw_colored_polygon(PackedVector2Array([
			Vector2(8.5, -1.4), Vector2(2.0, -2.2), Vector2(2.0, -0.4), Vector2(8.0, 0.0)]), brass_dark)

	# --- torso: a chamfered brass barrel ------------------------------------
	# The cut corners are what break the starter's plain rectangle outline.
	var barrel := PackedVector2Array([
		Vector2(-7, -21), Vector2(-9, -18), Vector2(-9, -11), Vector2(-7, -8),
		Vector2(7, -8), Vector2(9, -11), Vector2(9, -18), Vector2(7, -21)])
	draw_colored_polygon(barrel, casing)
	var barrel_in := PackedVector2Array([
		Vector2(-6, -20), Vector2(-7.5, -17.5), Vector2(-7.5, -11.5), Vector2(-6, -9.5),
		Vector2(6, -9.5), Vector2(7.5, -11.5), Vector2(7.5, -17.5), Vector2(6, -20)])
	draw_colored_polygon(barrel_in, brass)
	draw_rect(Rect2(-7.5, -15.5, 15.0, 1.2), brass_dark)               # rivet seam
	for i in range(3):
		draw_circle(Vector2(-5.0 + float(i) * 5.0, -14.9), 0.85, tin)  # rivets
	# ratchet plate on the chest, on the facing side
	draw_rect(Rect2(f * 1.5 - 2.5, -13.0, 5.0, 3.5), brass_dark)
	draw_rect(Rect2(-7.5, -9.5, 15.0, 1.5), brass_dark)                # hip band

	# --- head: narrow dome with one lens ------------------------------------
	draw_rect(Rect2(-3.0, -22.5, 6.0, 2.0), casing)                    # neck collar
	var dome := PackedVector2Array([
		Vector2(-6, -21.5), Vector2(-6, -25), Vector2(-4, BODY_TOP_Y),
		Vector2(4, BODY_TOP_Y), Vector2(6, -25), Vector2(6, -21.5)])
	draw_colored_polygon(dome, casing)
	var dome_in := PackedVector2Array([
		Vector2(-5, -22), Vector2(-5, -24.7), Vector2(-3.4, -26.6),
		Vector2(3.4, -26.6), Vector2(5, -24.7), Vector2(5, -22)])
	draw_colored_polygon(dome_in, brass)
	draw_circle(Vector2(f * 1.8, -24.2), 2.5, casing)                  # lens bezel
	draw_circle(Vector2(f * 1.8, -24.2), 1.8, lens)
	draw_circle(Vector2(f * 2.4, -24.9), 0.7, glint)
