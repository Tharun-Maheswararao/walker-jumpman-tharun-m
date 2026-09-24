extends SceneTree
## Renders SPROCKET in the four states the assignment asks to see -- standing,
## running right, running left, airborne -- with the UNCHANGED 18x28 collider
## drawn over each one, so the visual/collision alignment can be judged rather
## than asserted. Magenta outline = the real collider rectangle, read from the
## player's own constants.
##
## Run: godot --path godot --script res://tools/capture_character.gd
## Writes: evidence/screens/character-sheet.png

const Player = preload("res://features/player/player.gd")

const SPACING := 36.0
const FEET_Y := 52.0
const FIRST_X := 28.0

var players: Array[CharacterBody2D] = []
var labels: Array[String] = ["STANDING", "RUN RIGHT", "RUN LEFT", "AIRBORNE"]
var world: Node2D

func _initialize() -> void:
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame

func _add_floor(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2.0
	body.collision_layer = 1
	body.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	world.add_child(body)

func run() -> void:
	world = Node2D.new()
	root.add_child(world)

	var backdrop := Backdrop.new()
	world.add_child(backdrop)

	# Wide floor so the runners cannot leave it while building up speed. Cell 3
	# is airborne because it is never enabled, not because it runs off an edge.
	_add_floor(Rect2(-400, FEET_Y, 1200, 40))

	for i in range(4):
		var p := Player.new()
		world.add_child(p)
		p.reset_at(Vector2(FIRST_X + SPACING * float(i), FEET_Y))
		p.test_control = true
		players.append(p)

	# 0: standing, grounded, no input.
	players[0].enabled = true
	players[0].test_axis = 0.0
	# 1: running right.
	players[1].enabled = true
	players[1].test_axis = 1.0
	# 2: running left.
	players[2].enabled = true
	players[2].test_axis = -1.0
	# 3: airborne. Never enabled, so is_on_floor() stays false and the pose is
	# the true airborne pose: pistons retracted, winding key held still.
	players[3].enabled = false
	players[3].facing = 1.0

	# Let the runners reach full speed so the stride and key spin are live, then
	# freeze them and snap each one back into its own cell. Disabling the player
	# makes _physics_process return before move_and_slide, so is_on_floor() and
	# velocity keep the values that select the pose -- only the position moves.
	for i in range(24):
		await step()
	players[1].enabled = false
	players[2].enabled = false
	for i in range(players.size()):
		players[i].position = Vector2(FIRST_X + SPACING * float(i), FEET_Y)

	var overlay := Overlay.new()
	overlay.players = players
	overlay.labels = labels
	world.add_child(overlay)

	var camera := Camera2D.new()
	camera.position = Vector2(FIRST_X + SPACING * 1.5, 36)
	camera.zoom = Vector2(4, 4)
	world.add_child(camera)
	camera.make_current()

	await step()
	await step()
	await RenderingServer.frame_post_draw
	var out := ProjectSettings.globalize_path("res://../evidence/screens")
	DirAccess.make_dir_recursive_absolute(out)
	var err := root.get_texture().get_image().save_png(out + "/character-sheet.png")
	assert(err == OK, "could not write character sheet")
	print("Wrote evidence/screens/character-sheet.png")
	print("collider = %s at offset %s" % [str(Player.COLLIDER_SIZE), str(Player.COLLIDER_OFFSET)])
	print("key overhang past the collider wall = %.2f px" % Player.KEY_OVERHANG_PX)
	quit(0)


class Backdrop extends Node2D:
	func _ready() -> void:
		z_index = -10
	func _draw() -> void:
		draw_rect(Rect2(-200, -200, 800, 600), Color("f6f3ec"))
		for x in range(-100, 300, 8):
			draw_line(Vector2(x, -100), Vector2(x, 300), Color("e7e5df"), 0.5)
		for y in range(-100, 300, 8):
			draw_line(Vector2(-100, y), Vector2(300, y), Color("e7e5df"), 0.5)


class Overlay extends Node2D:
	var players: Array[CharacterBody2D]
	var labels: Array[String]

	func _ready() -> void:
		z_index = 50

	func _draw() -> void:
		var font := ThemeDB.fallback_font
		var half: Vector2 = Player.COLLIDER_SIZE / 2.0
		for i in range(players.size()):
			var p: CharacterBody2D = players[i]
			var centre: Vector2 = p.position + Player.COLLIDER_OFFSET
			var box := Rect2(centre - half, Player.COLLIDER_SIZE)
			draw_rect(box, Color(0.85, 0.1, 0.55, 1.0), false, 0.4)
			var lw := font.get_string_size(labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 4).x
			draw_string(font, Vector2(p.position.x - lw / 2.0, p.position.y + 9),
				labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 4, Color("2b2118"))
			var tag := "facing %s" % ("R" if p.facing > 0 else "L")
			var tw := font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 3).x
			draw_string(font, Vector2(p.position.x - tw / 2.0, p.position.y + 14),
				tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 3, Color("8a5f27"))
		draw_string(font, Vector2(FIRST_X - 22, 14), "SPROCKET  /  unchanged 18x28 collider drawn in magenta",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 4, Color("2b2118"))
