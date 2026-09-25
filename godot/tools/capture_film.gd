extends SceneTree
## Records real gameplay clips for the Brutalist godot-waikthrough film using
## Godot's Movie Maker (--write-movie), so every frame is genuine engine output
## rendered deterministically at native 3840x2160.
##
## INPUT INTEGRITY (capture-and-coverage.md)
## This driver goes through the REAL input path: Input.action_press /
## Input.action_release for move and jump, and parsed InputEventKey for
## Enter / Escape / R / M. `test_control` stays FALSE, so the player reads the
## same Input singleton a human's keyboard drives. The driver observes position
## and state to decide when to press a key -- which the reference permits -- but
## it never sets position, never sets velocity, never sets state, never disables
## a collision check, and never calls a completion shortcut.
##
## Deaths in these clips come from the game's own fall/hazard checks and
## completions from the goal Area2D. The failure clip reproduces the failure
## mode the human playtester actually hit (TEST-REPORT 7.2) -- leaving a
## platform too early -- by pressing Space early, not by moving the player.
##
## Run (one clip per invocation):
##   godot --path godot --write-movie <out.avi> --fixed-fps 30 \
##         --script res://tools/capture_film.gd -- <clip>
##
## 640x360 viewport x6 = 3840x2160 exactly: 4K by integer scaling, not upscaling.

const Game = preload("res://game/session.gd")

## x positions at which to press Space, per route.
const HIGH_ROAD: Array[float] = [138, 292, 424, 548, 712, 946, 1170, 1306, 1442, 1596, 1740]
const LOW_ROAD_OUT: Array[float] = [138, 292, 424, 548, 712, 946, 1170, 1306, 1442, 1900]
## Correct up to The Junction, then leave 70px early. Max centre travel is
## 112px, so from x=1100 the furthest reachable centre is 1212, and stepping
## stone 1's landing window does not open until 1247: a 35px short fall.
const EARLY: Array[float] = [138, 292, 424, 548, 712, 946, 1100]

const LANDMARKS: Array = [
	[138.0, "reached x=138 (first gap lip)"], [330.0, "reached x=330 (original spike)"],
	[600.0, "reached x=600 (second ledge)"], [1024.0, "reached x=1024 (The Junction)"],
	[1256.0, "reached x=1256 (stepping stone 1)"], [1392.0, "reached x=1392 (stepping stone 2)"],
	[1520.0, "reached x=1520 (ground run)"], [1596.0, "reached x=1596 (launch guide)"],
	[1664.0, "reached x=1664 (terrace near edge)"], [1760.0, "reached x=1760 (terrace spike bank)"],
	[1824.0, "reached x=1824 (flag)"], [1960.0, "reached x=1960 (climb-out buttress)"],
]

var game: Node2D
var clip: String = "high-road"
var frames: int = 0
var log_lines: Array = []
var landmark_hits := {}
var held := {}

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		clip = args[0]
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame
	frames += 1
	_landmarks()

func at() -> float:
	return snappedf(float(frames) / 30.0, 0.001)

func note(text: String) -> void:
	log_lines.append({"frame": frames, "seconds": at(), "event": text})
	print("[%05d %6.2fs] %s" % [frames, at(), text])

## --- real input -------------------------------------------------------------
func press(action: String) -> void:
	if not held.get(action, false):
		Input.action_press(action)
		held[action] = true
		log_lines.append({"frame": frames, "seconds": at(), "input": action, "edge": "press"})

func release(action: String) -> void:
	if held.get(action, false):
		Input.action_release(action)
		held[action] = false
		log_lines.append({"frame": frames, "seconds": at(), "input": action, "edge": "release"})

func release_all() -> void:
	for action in held.keys():
		if held[action]:
			release(action)

func tap_key(code: Key, label: String) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await step()
		await step()
	log_lines.append({"frame": frames, "seconds": at(), "input": label, "edge": "tap"})

func hold_frames(n: int) -> void:
	for i in range(n):
		await step()

func _landmarks() -> void:
	if game == null or game.player == null:
		return
	for entry in LANDMARKS:
		var key: String = entry[1]
		if landmark_hits.has(key) or game.player.position.x < float(entry[0]):
			continue
		landmark_hits[key] = frames
		log_lines.append({"frame": frames, "seconds": at(),
			"x": snappedf(game.player.position.x, 0.1), "y": snappedf(game.player.position.y, 0.1),
			"on_floor": game.player.is_on_floor(), "event": key})

## Run right, pressing Space at each mark. Returns when the attempt ends.
func run_route(marks: Array[float], budget: int, stop_on_death := true, stop_x := 0.0) -> void:
	var index := 0
	var last_state: int = game.state
	press("move_right")
	for i in range(budget):
		if index < marks.size() and game.player.position.x >= marks[index] and game.player.is_on_floor():
			press("jump")
			index += 1
		elif held.get("jump", false):
			release("jump")
		await step()
		if game.state != last_state:
			match game.state:
				Game.State.DYING: note("DEATH (real, from the game's own fall/hazard check): " + str(game.death_reason))
				Game.State.COMPLETE: note("COMPLETE at x=%.1f" % game.player.position.x)
				Game.State.PLAYING: note("respawned at x=%.1f" % game.player.position.x)
			last_state = game.state
			if stop_on_death and game.state == Game.State.DYING:
				release_all()
				return
		if game.state == Game.State.COMPLETE:
			break
		if stop_x > 0.0 and game.player.position.x >= stop_x and game.player.is_on_floor():
			note("arrived at the climb-out buttress: x=%.1f" % game.player.position.x)
			break
	release_all()

func run() -> void:
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	await hold_frames(4)

	match clip:
		"menu":
			await hold_frames(55)
			await tap_key(KEY_ENTER, "Enter")
			note("Enter started the session from the title card")
			await hold_frames(85)

		"high-road":
			await tap_key(KEY_ENTER, "Enter")
			note("HIGH ROAD, real Input actions, no teleports")
			await run_route(HIGH_ROAD, 1500)
			await hold_frames(70)

		"low-road":
			await tap_key(KEY_ENTER, "Enter")
			note("LOW ROAD out to the buttress")
			await run_route(LOW_ROAD_OUT, 1500, false, 1985.0)
			note("turning back left toward the flag")
			press("move_left")
			var turned := 0
			while game.state == Game.State.PLAYING and turned < 400:
				if game.player.position.x <= 1958.0 and game.player.is_on_floor():
					press("jump")
				elif held.get("jump", false):
					release("jump")
				await step()
				turned += 1
				if game.state == Game.State.COMPLETE:
					note("COMPLETE at x=%.1f" % game.player.position.x)
					break
			release_all()
			await hold_frames(70)

		"failure-recovery":
			await tap_key(KEY_ENTER, "Enter")
			note("FAILURE: Space pressed 70px early leaving The Junction")
			await run_route(EARLY, 1500)
			while game.state != Game.State.PLAYING:
				await step()
			note("auto-retry complete, replaying the correct line")
			await run_route(HIGH_ROAD, 1500)
			await hold_frames(70)

		"controls":
			# Title card first, so the menu and the Enter that starts a session
			# are genuinely on screen long enough to be cited as evidence, then
			# pause / resume / manual restart / main menu, all via real keys.
			await hold_frames(45)
			await tap_key(KEY_ENTER, "Enter")
			note("Enter started the session from the title card")
			press("move_right")
			await hold_frames(30)
			press("jump")
			await hold_frames(2)
			release("jump")
			await hold_frames(8)
			var y_before: float = game.player.position.y
			await tap_key(KEY_ESCAPE, "Escape")
			note("Escape pressed mid-jump: state=%d, y frozen at %.2f" % [game.state, y_before])
			await hold_frames(45)
			note("still frozen after 45 frames: y=%.2f (delta %.4f)" % [game.player.position.y, game.player.position.y - y_before])
			await tap_key(KEY_ENTER, "Enter")
			note("Enter resumed: state=%d, jumps=%d (no free jump granted)" % [game.state, game.player.jumps])
			# Stop short of the original spike at x=320 so the retry counter is
			# only ever moved by R, if it moves at all. A stray spike death here
			# would make the "manual restart is not a death" claim unreadable.
			await hold_frames(12)
			release("move_right")
			await hold_frames(6)
			var deaths_before: int = game.deaths
			note("before R: x=%.1f deaths=%d" % [game.player.position.x, deaths_before])
			await tap_key(KEY_R, "R")
			note("after  R: x=%.1f deaths=%d (unchanged: a manual restart is not a death)" % [game.player.position.x, game.deaths])
			await hold_frames(35)
			release_all()
			await tap_key(KEY_ESCAPE, "Escape")
			await tap_key(KEY_M, "M")
			note("M returned to the main menu: state=%d" % game.state)
			await hold_frames(45)

		"replay":
			await tap_key(KEY_ENTER, "Enter")
			await run_route(HIGH_ROAD, 1500)
			await hold_frames(55)
			await tap_key(KEY_ENTER, "Enter")
			note("Enter replayed from the completion card: deaths=%d jumps=%d" % [game.deaths, game.player.jumps])
			press("move_right")
			await hold_frames(90)
			release_all()

		_:
			push_error("unknown clip: " + clip)
			quit(1)
			return

	release_all()
	var out := ProjectSettings.globalize_path("res://../evidence/film")
	DirAccess.make_dir_recursive_absolute(out)
	var report := {
		"clip": clip,
		"engine": Engine.get_version_info().string,
		"frames": frames,
		"fps": 30,
		"capture": "Godot Movie Maker (--write-movie --fixed-fps 30), deterministic offline render of the real viewport at 3840x2160",
		"input_method": "real Input singleton: Input.action_press/action_release plus parsed InputEventKey; test_control is false",
		"no_teleport": true,
		"no_state_writes": true,
		"final_state": game.state,
		"deaths": game.deaths,
		"elapsed_s": game.elapsed,
		"events": log_lines,
	}
	var file := FileAccess.open(out + "/inputlog-" + clip + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	print("CLIP %s: %d frames, state=%d deaths=%d" % [clip, frames, game.state, game.deaths])
	quit(0)
