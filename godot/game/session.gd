extends Node2D

const Player = preload("res://features/player/player.gd")
const Hud = preload("res://ui/hud.gd")
enum State { MENU, PLAYING, PAUSED, DYING, COMPLETE }
var state: State = State.MENU
var player: CharacterBody2D
var camera: Camera2D
var hud: Control
var level: Dictionary
var hazard_areas: Array[Area2D] = []
var goal: Area2D
var deaths: int = 0
var elapsed: float = 0.0
var retry_remaining: float = 0.0
var death_reason: String = ""
var last_finish_time: float = 0.0
var test_mode: bool = false
var contact_settle_ticks: int = 0

func _ready() -> void:
	process_physics_priority = 10
	level = JSON.parse_string(FileAccess.get_file_as_string("res://levels/first_steps.json"))
	_setup_input()
	for entry in level.solids:
		_add_solid(Rect2(entry[0], entry[1], entry[2], entry[3]))
	_add_solid(Rect2(-32, 0, 32, 430))
	_add_solid(Rect2(level.width, 0, 32, 430))
	for entry in level.hazards:
		hazard_areas.append(_add_area(Rect2(entry[0], entry[1], entry[2], entry[3]), 8, true))
	var f: Array = level.finish
	goal = _add_area(Rect2(f[0], f[1], f[2], f[3]), 16, false)
	player = Player.new()
	add_child(player)
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	camera = Camera2D.new()
	camera.position = Vector2(320, 180)
	add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.game = self
	layer.add_child(hud)
	get_window().focus_exited.connect(_on_focus_lost)
	queue_redraw()

func _setup_input() -> void:
	var actions := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE], "pause": [KEY_ESCAPE, KEY_P], "restart": [KEY_R], "confirm": [KEY_ENTER], "menu": [KEY_M]}
	for action in actions:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in actions[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _add_solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2
	body.collision_layer = 1
	body.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

## The one definition of a spike's shape. _add_area() builds the trigger from
## it and _draw() paints from it, so the picture and the hit test cannot drift
## apart. The starter had two copies of this geometry and the drawing copy had
## y hard-coded to the ground line, which put any raised hazard's art 64px away
## from its trigger.
static func hazard_triangle(rect: Rect2, index: int) -> PackedVector2Array:
	var x: float = rect.position.x + float(index) * rect.size.x / 3.0
	var base: float = rect.position.y + rect.size.y
	return PackedVector2Array([
		Vector2(x, base),
		Vector2(x + 4, rect.position.y),
		Vector2(x + 8, base)])

func _add_area(rect: Rect2, layer: int, spikes: bool) -> Area2D:
	var area := Area2D.new()
	area.position = rect.position
	area.collision_layer = layer
	area.collision_mask = 2
	if spikes:
		# Three exact triangular trigger silhouettes; no oversized invisible box.
		# Local to area.position, so the rect passed in starts at the origin.
		for i in range(3):
			var triangle := CollisionPolygon2D.new()
			triangle.polygon = hazard_triangle(Rect2(Vector2.ZERO, rect.size), i)
			area.add_child(triangle)
	else:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		collision.position = rect.size / 2.0
		area.add_child(collision)
	add_child(area)
	return area

func start_session() -> void:
	if state == State.PLAYING:
		return
	deaths = 0
	restart_attempt()

func restart_attempt() -> void:
	state = State.PLAYING
	elapsed = 0.0
	retry_remaining = 0.0
	# Area2D overlaps are physics-step snapshots. Discard pre-teleport contacts
	# until the broadphase has observed the reset, preventing a phantom second death.
	contact_settle_ticks = 2
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	player.enabled = true
	camera.position = Vector2(320, 180)

func set_paused(value: bool) -> void:
	if value and state == State.PLAYING:
		state = State.PAUSED
		player.enabled = false
	elif not value and state == State.PAUSED:
		state = State.PLAYING
		player.enabled = true
		player.require_jump_release = true
		player.jump_request_tick = -1000

func _on_focus_lost() -> void:
	if not test_mode:
		set_paused(true)

func resolve_contacts(fatal: bool, finished: bool) -> void:
	if state != State.PLAYING:
		return
	if fatal:
		state = State.DYING
		deaths += 1
		retry_remaining = 0.55
		player.enabled = false
		player.velocity = Vector2.ZERO
	elif finished:
		state = State.COMPLETE
		last_finish_time = elapsed
		player.enabled = false
		player.velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if state == State.DYING:
		retry_remaining -= delta
		if retry_remaining <= 0:
			restart_attempt()
	elif state == State.PLAYING:
		elapsed += delta
		var fatal := player.position.y > float(level.fall_y)
		death_reason = "Missed the landing" if fatal else "Watch the spikes"
		for hazard in hazard_areas:
			fatal = fatal or hazard.overlaps_body(player)
		if contact_settle_ticks > 0:
			contact_settle_ticks -= 1
		else:
			resolve_contacts(fatal, goal.overlaps_body(player))
		camera.position.x = clampf(player.position.x + 100, 320, float(level.width) - 320)
	if is_instance_valid(hud):
		hud.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("confirm"):
		if state in [State.MENU, State.COMPLETE]:
			start_session()
		elif state == State.PAUSED:
			set_paused(false)
	elif event.is_action_pressed("pause"):
		set_paused(state != State.PAUSED)
	elif event.is_action_pressed("restart") and state in [State.PLAYING, State.PAUSED, State.DYING]:
		restart_attempt()
	elif event.is_action_pressed("menu") and state in [State.PAUSED, State.COMPLETE]:
		state = State.MENU
		player.enabled = false
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(220, 215, 200, 34).has_point(hud.get_local_mouse_position()):
			if state in [State.MENU, State.COMPLETE]:
				start_session()
			elif state == State.PAUSED:
				set_paused(false)

func _draw() -> void:
	if level.is_empty():
		return
	var font := ThemeDB.fallback_font
	var ink := Color("25354a")
	var width: float = float(level.width)
	# All visual assets are original Godot vector drawing, not recovered art.
	# Everything below is sized from the level data. The starter hard-coded a
	# 1800px backdrop, a 960px grid, three hill positions, the hazard baseline
	# and the finish pole height, so widening the level alone left the new
	# ground with no backdrop and drew raised hazards down at the old ground line.
	draw_rect(Rect2(-400, -200, width + 800, 900), Color("f6f3ec"))
	for x in range(0, int(width) + 32, 32):
		draw_line(Vector2(x, 80), Vector2(x, 320), Color("e7e5df"), 1)
	for y in range(96, 321, 32):
		draw_line(Vector2(0, y), Vector2(width, y), Color("e7e5df"), 1)
	for x in level.hills:
		draw_colored_polygon(PackedVector2Array([Vector2(x-90,320),Vector2(x+50,180),Vector2(x+190,320)]), Color("e4e8e3"))
	for entry in level.solids:
		var r := Rect2(entry[0], entry[1], entry[2], entry[3])
		draw_rect(r, ink)
		draw_rect(Rect2(r.position, Vector2(r.size.x, 4)), Color("438e7d"))
		for x in range(int(r.position.x)+12, int(r.end.x), 24):
			draw_line(Vector2(x, r.position.y+12), Vector2(x+7, r.position.y+19), Color("405166"), 1)
	# Painted launch guides. No collision: these are floor markings that tell the
	# player where a jump has to start. The one on the ground run is placed over
	# the measured take-off window for the 48px Terrace jump (tools/probe_jump.gd),
	# so the paint and the physics describe the same window. Without it the
	# natural thing to do is run up under the Terrace and jump, which bonks.
	for entry in level.guides:
		var guide := Rect2(entry[0], entry[1], entry[2], entry[3])
		draw_rect(guide, Color(0.157, 0.486, 0.408, 0.20))
		for x in range(int(guide.position.x), int(guide.end.x), 10):
			draw_line(Vector2(x, guide.end.y), Vector2(x + 5, guide.position.y), Color(0.157, 0.486, 0.408, 0.75), 1.5)
			draw_line(Vector2(x + 5, guide.position.y), Vector2(x + 10, guide.end.y), Color(0.157, 0.486, 0.408, 0.75), 1.5)
	for entry in level.hazards:
		var hazard := Rect2(entry[0], entry[1], entry[2], entry[3])
		for i in range(3):
			draw_colored_polygon(hazard_triangle(hazard, i), Color("d24e42"))
	# Finish marker drawn from the goal rect, so the pole stands exactly as tall
	# as the trigger the player actually has to touch.
	var f: Array = level.finish
	var finish_x: float = f[0]
	var finish_top: float = f[1]
	var finish_base: float = float(f[1]) + float(f[3])
	draw_line(Vector2(finish_x+3, finish_base), Vector2(finish_x+3, finish_top), ink, 3)
	draw_colored_polygon(PackedVector2Array([
		Vector2(finish_x+5, finish_top),
		Vector2(finish_x+32, finish_top+10),
		Vector2(finish_x+5, finish_top+24)]), Color("287c68"))
	for entry in level.labels:
		draw_string(font, Vector2(entry[0], entry[1]), entry[3], HORIZONTAL_ALIGNMENT_LEFT, -1, int(entry[2]), ink)
