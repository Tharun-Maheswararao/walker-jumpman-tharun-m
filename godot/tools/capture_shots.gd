extends SceneTree
## Captures the real rendered game viewport at points along the actual scripted
## routes. Nothing here is a mock-up or a reconstructed interface: every frame
## is the shipped game running its own physics, driven by the same scripted
## input the regression tests use.
##
## Run: godot --path godot --script res://tools/capture_shots.gd
## Writes: evidence/screens/*.png

const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")

var game: Node2D
var output: String

func _initialize() -> void:
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output + "/" + label + ".png")
	assert(error == OK, "could not write " + label)
	print("captured %s" % label)

func fresh() -> void:
	if is_instance_valid(game):
		game.queue_free()
		await process_frame
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	for i in range(3):
		await step()

## Run a route and capture whenever the player first passes each x threshold.
func run_route(plan: Array, budget: int, shots: Array) -> void:
	game.start_session()
	game.player.test_control = true
	var route = Route.new(plan)
	var pending := shots.duplicate()
	for i in range(budget):
		route.step(game.player)
		await step()
		if not pending.is_empty():
			var shot: Dictionary = pending[0]
			var x_ok: bool = game.player.position.x >= float(shot["x"])
			var airborne_ok: bool = (not shot.has("airborne")) or (not game.player.is_on_floor())
			if x_ok and airborne_ok:
				await capture(shot["name"])
				pending.pop_front()
		if game.state != Game.State.PLAYING:
			break

func run() -> void:
	output = ProjectSettings.globalize_path("res://../evidence/screens")
	DirAccess.make_dir_recursive_absolute(output)

	await fresh()
	await capture("10-menu")

	# --- the HIGH ROAD, played by the scripted route ------------------------
	await run_route(Route.HIGH_ROAD, 1500, [
		{"name": "11-original-section", "x": 300.0},
		{"name": "12-junction-and-stones", "x": 1080.0},
		{"name": "13-stone-hop", "x": 1290.0, "airborne": true},
		{"name": "14-the-fork", "x": 1570.0},
		{"name": "15-terrace-and-raised-spikes", "x": 1700.0},
		{"name": "16-finish-approach", "x": 1800.0},
	])
	assert(game.state == Game.State.COMPLETE, "high road route did not complete")
	await capture("17-complete")

	# --- the LOW ROAD, under the terrace and back ---------------------------
	await fresh()
	await run_route(Route.LOW_ROAD, 2000, [
		{"name": "18-low-road-under-terrace", "x": 1780.0},
		{"name": "19-climb-out-buttress", "x": 1975.0},
	])
	assert(game.state == Game.State.COMPLETE, "low road route did not complete")
	await capture("20-low-road-complete")

	# --- a real failure on the new spike bank -------------------------------
	await fresh()
	game.start_session()
	game.player.test_control = true
	game.player.test_axis = 1
	game.player.position = Vector2(1735, 272)
	for i in range(90):
		await step()
		if game.state == Game.State.DYING:
			break
	assert(game.state == Game.State.DYING, "walking into the terrace spikes did not kill")
	await capture("21-terrace-spike-failure")

	# --- a real failure by missing a stone ----------------------------------
	await fresh()
	game.start_session()
	game.player.test_control = true
	game.player.test_axis = 1
	game.player.position = Vector2(1200, 330)
	for i in range(90):
		await step()
		if game.state == Game.State.DYING:
			break
	assert(game.state == Game.State.DYING, "falling into a new pit did not kill")
	await capture("22-missed-landing-failure")

	print("SHOTS: done")
	game.queue_free()
	await process_frame
	quit(0)
