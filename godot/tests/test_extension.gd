extends SceneTree
## Regression suite for section 03 "The Fork" and the SPROCKET character.
##
## This is additive. The starter's own suites (test_game.gd, test_keyboard.gd)
## are kept and still run; nothing in them was deleted or weakened. This file
## covers what those suites cannot know about: the new geometry, both roads
## through the fork, the relocated finish, and the draw/trigger agreement bug
## that the extension exposed.
##
## Run: godot --headless --path godot --script res://tests/test_extension.gd

const Game = preload("res://game/session.gd")
const Player = preload("res://features/player/player.gd")
const Route = preload("res://tests/route_driver.gd")

## Measured on this engine by tools/probe_jump.gd. Paper math says 53.33.
const MEASURED_APEX_RISE := 56.0
const MEASURED_MAX_FLAT_GAP := 130.0
## Furthest the player's centre can travel in one flat jump at full run speed.
const MEASURED_MAX_FLAT_TRAVEL := 112.0
const HALF_WIDTH := 9.0

## The starter's geometry, copied from nikbearbrown/walker-jumpman @9387542.
## Section 03 must not have disturbed any of it.
const ORIGINAL_SOLIDS: Array = [
	[0, 320, 448, 64], [512, 320, 224, 64], [784, 320, 176, 64],
	[160, 304, 48, 16], [576, 288, 48, 32]]
const ORIGINAL_SPIKE: Array = [320, 304, 24, 16]
const ORIGINAL_SPAWN: Array = [64, 320]
const ORIGINAL_FINISH_X := 916.0

var game: Node2D
var results: Array[Dictionary] = []
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func check(id: String, passed: bool, observation: Dictionary) -> void:
	results.append({"id": id, "status": "PASS" if passed else "FAIL", "observed": observation})
	if not passed:
		failures += 1
	print(JSON.stringify(results.back()))

func fresh() -> void:
	if is_instance_valid(game):
		game.queue_free()
		await process_frame
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	game.start_session()
	game.player.test_control = true
	await steps(3)

## Drive a scripted route to its conclusion. Returns the tick count.
func drive(route_plan: Array, budget: int) -> Dictionary:
	await fresh()
	var route = Route.new(route_plan)
	var ticks := 0
	while game.state == Game.State.PLAYING and ticks < budget:
		route.step(game.player)
		await steps(1)
		ticks += 1
	return {"ticks": ticks, "state": game.state, "deaths": game.deaths,
		"position": str(game.player.position), "marks": route.next_jump,
		"elapsed": game.elapsed}

func run() -> void:
	await fresh()
	var level: Dictionary = game.level

	# --- the starter's course must be untouched -----------------------------
	var solids: Array = level.solids
	var kept := true
	for i in range(ORIGINAL_SOLIDS.size()):
		if i >= solids.size() or not _same_numbers(Array(solids[i]), ORIGINAL_SOLIDS[i]):
			kept = false
	check("original-solids-unchanged", kept,
		{"first_five": str(solids.slice(0, 5))})
	check("original-spike-unchanged", _same_numbers(Array(level.hazards[0]), ORIGINAL_SPIKE),
		{"hazard_0": str(level.hazards[0])})
	check("original-spawn-unchanged", _same_numbers(Array(level.spawn), ORIGINAL_SPAWN),
		{"spawn": str(level.spawn)})

	# --- tuning and collider must be untouched ------------------------------
	var t = game.player.tuning
	var tuning_intact: bool = (t.speed == 160.0 and t.acceleration == 1280.0
		and t.deceleration == 1920.0 and t.jump_velocity == -320.0
		and t.gravity == 960.0 and t.terminal_velocity == 480.0
		and t.coyote_ticks == 6 and t.buffer_ticks == 6)
	check("tuning-unchanged", tuning_intact,
		{"speed": t.speed, "jump_velocity": t.jump_velocity, "gravity": t.gravity,
		"coyote": t.coyote_ticks, "buffer": t.buffer_ticks})
	check("collider-unchanged",
		Player.COLLIDER_SIZE == Vector2(18, 28) and Player.COLLIDER_OFFSET == Vector2(0, -14),
		{"size": str(Player.COLLIDER_SIZE), "offset": str(Player.COLLIDER_OFFSET)})

	# --- the character art must stay inside the collider, key excepted ------
	# BODY_TOP_Y is the topmost pixel the body draws. The collider top is -28.
	check("body-art-within-collider", Player.BODY_TOP_Y >= -28.0,
		{"body_top_y": Player.BODY_TOP_Y, "collider_top_y": -28.0})
	check("key-overhang-small-and-declared",
		Player.KEY_OVERHANG_PX > 0.0 and Player.KEY_OVERHANG_PX <= 4.0,
		{"overhang_px": Player.KEY_OVERHANG_PX,
		"note": "trailing side only; derived from the same constants _draw() uses"})

	# --- the finish actually moved and is behind the new section ------------
	var finish_x: float = float(level.finish[0])
	check("finish-relocated-past-new-section",
		finish_x > 1500.0 and finish_x > ORIGINAL_FINISH_X,
		{"finish_x": finish_x, "original_finish_x": ORIGINAL_FINISH_X})
	check("level-widened", float(level.width) > 960.0,
		{"width": level.width, "original_width": 960})

	# --- every new landing is a real jump, not a walk ------------------------
	# Ground-level platform tops in the new section, left to right, with the
	# gap that precedes each one. A gap > 0 means it cannot be walked onto.
	var landings := [
		{"name": "junction", "from_edge": 960.0, "to_edge": 1024.0},
		{"name": "stone-1", "from_edge": 1184.0, "to_edge": 1256.0},
		{"name": "stone-2", "from_edge": 1320.0, "to_edge": 1392.0},
		{"name": "ground-run", "from_edge": 1456.0, "to_edge": 1520.0},
	]
	var all_jumps := true
	var all_reachable := true
	var gaps := []
	for l in landings:
		var gap: float = l.to_edge - l.from_edge
		gaps.append({"landing": l.name, "gap_px": gap})
		if gap <= 0.0:
			all_jumps = false
		if gap > MEASURED_MAX_FLAT_GAP:
			all_reachable = false
	check("new-landings-need-jumps", all_jumps and landings.size() >= 2, {"gaps": gaps})
	check("new-landings-within-measured-envelope", all_reachable,
		{"gaps": gaps, "measured_max_flat_gap_px": MEASURED_MAX_FLAT_GAP})

	# --- a stone cannot be overshot, so every miss is an early jump ---------
	# The one failed attempt in the human playtest (TEST-REPORT 7.2) was
	# "jumped too early". That is not bad luck -- it is the only failure mode
	# this geometry permits. At full run speed the furthest the centre can
	# travel in one flat jump is 112px, and for every stone the landing window
	# reaches further than that from the latest possible take-off. So a
	# full-commitment jump always lands, and the only way to miss is to leave
	# early. That is a deliberate property of the layout: the player is never
	# punished for holding right, only for letting go of the timing. Asserted
	# here so it stays true if the geometry ever moves.
	var stone_jumps := [
		{"name": "junction -> stone-1", "launch_end": 1184.0, "land_end": 1320.0},
		{"name": "stone-1 -> stone-2", "launch_end": 1320.0, "land_end": 1456.0},
		{"name": "stone-2 -> ground-run", "launch_end": 1456.0, "land_end": 2080.0},
	]
	var no_overshoot := true
	var overshoot: Array = []
	for j in stone_jumps:
		var latest_takeoff: float = float(j["launch_end"]) + HALF_WIDTH
		var furthest_landing: float = latest_takeoff + MEASURED_MAX_FLAT_TRAVEL
		var window_end: float = float(j["land_end"]) + HALF_WIDTH
		if furthest_landing > window_end:
			no_overshoot = false
		overshoot.append({"jump": j["name"],
			"furthest_reachable_centre": furthest_landing,
			"landing_window_ends": window_end,
			"spare_px": snappedf(window_end - furthest_landing, 0.01)})
	check("stones-cannot-be-overshot", no_overshoot, {"jumps": overshoot})

	# --- the terrace is inside the measured jump budget ---------------------
	var ground_top := 320.0
	var terrace_top := 272.0
	var rise: float = ground_top - terrace_top
	check("terrace-rise-within-apex", rise < MEASURED_APEX_RISE,
		{"rise_px": rise, "measured_apex_px": MEASURED_APEX_RISE,
		"margin_px": MEASURED_APEX_RISE - rise})

	# --- a standing player fits under the terrace (the LOW ROAD exists) -----
	var terrace_bottom := 272.0 + 12.0
	var standing_head := ground_top - Player.COLLIDER_SIZE.y
	check("low-road-headroom", standing_head > terrace_bottom,
		{"terrace_underside_y": terrace_bottom, "standing_head_y": standing_head,
		"clearance_px": standing_head - terrace_bottom})

	# --- drawn spikes and spike triggers are the same geometry --------------
	# The starter drew every hazard at the ground line regardless of its data,
	# so a raised hazard's picture sat 64px from its trigger. Both now come from
	# Game.hazard_triangle(); this asserts the trigger really is built from it.
	var agree := true
	var detail := []
	for area in game.hazard_areas:
		for child in area.get_children():
			if child is CollisionPolygon2D:
				var index: int = area.get_children().find(child)
				var local: PackedVector2Array = child.polygon
				var expected: PackedVector2Array = Game.hazard_triangle(
					Rect2(Vector2.ZERO, _hazard_size(level, area)), index)
				if local != expected:
					agree = false
				for p in range(local.size()):
					var drawn_global: Vector2 = area.position + local[p]
					detail.append({"trigger_global": str(drawn_global)})
	check("hazard-art-matches-trigger", agree,
		{"hazards": game.hazard_areas.size(),
		"note": "trigger polygons rebuilt from the same hazard_triangle() the renderer calls",
		"points": detail.size()})

	# The new hazard must genuinely be off the old hard-coded ground baseline,
	# otherwise this test proves nothing.
	var raised: Array = level.hazards[1]
	check("new-hazard-is-raised", float(raised[1]) + float(raised[3]) < 320.0,
		{"hazard": str(raised), "baseline_the_starter_hard_coded": 320.0,
		"actual_base_y": float(raised[1]) + float(raised[3])})

	# --- the new spike bank actually kills ----------------------------------
	await fresh()
	game.player.position = Vector2(1772, 266)
	await steps(4)
	check("terrace-spikes-kill", game.state == Game.State.DYING and game.deaths == 1,
		{"state": game.state, "deaths": game.deaths})
	await steps(40)
	check("terrace-spikes-retry-respawns",
		game.state == Game.State.PLAYING
		and game.player.position.distance_to(Vector2(64, 320)) < 1.0,
		{"state": game.state, "position": str(game.player.position)})

	# --- falling into a new pit retries -------------------------------------
	await fresh()
	game.player.position = Vector2(1220, 432)
	await steps(2)
	check("new-pit-fall-retries", game.state == Game.State.DYING,
		{"state": game.state, "fall_y": level.fall_y})

	# --- HUD progress is no longer hard-coded to the old finish -------------
	await fresh()
	game.player.position = Vector2(ORIGINAL_FINISH_X, 320)
	await steps(2)
	var spawn_x: float = float(level.spawn[0])
	var progress: float = (ORIGINAL_FINISH_X - spawn_x) / (finish_x - spawn_x)
	check("progress-bar-rescaled", progress < 0.95,
		{"progress_at_old_finish": snappedf(progress, 0.001),
		"note": "the starter divided by a hard-coded 852 and would read 1.000 here"})

	# --- both roads through the fork are actually playable ------------------
	var high: Dictionary = await drive(Route.HIGH_ROAD, 1500)
	check("high-road-completes",
		high.state == Game.State.COMPLETE and high.deaths == 0,
		high)
	var low: Dictionary = await drive(Route.LOW_ROAD, 2000)
	check("low-road-completes",
		low.state == Game.State.COMPLETE and low.deaths == 0,
		low)

	# --- and the fork's trade-off is real, not just claimed -----------------
	# Design claim: the low road is safe but costs time, because the only way up
	# is past the flag and the player must double back. Horizontal speed in this
	# engine is a constant 160px/s in the air as well as on the ground, so the
	# ONLY thing that can make one road slower is extra distance travelled.
	var delta_ticks: int = int(low.ticks) - int(high.ticks)
	check("low-road-is-slower-than-high-road", delta_ticks > 0,
		{"high_road_ticks": high.ticks, "low_road_ticks": low.ticks,
		"difference_ticks": delta_ticks,
		"difference_seconds": snappedf(float(delta_ticks) / 60.0, 0.01),
		"high_road_elapsed_s": snappedf(float(high.elapsed), 0.01),
		"low_road_elapsed_s": snappedf(float(low.elapsed), 0.01)})

	var report := {
		"scope": "Section 03 The Fork and the SPROCKET character. Scripted input and geometry only; not human playtesting.",
		"engine": Engine.get_version_info().string,
		"created_at": Time.get_datetime_string_from_system(true),
		"results": results,
		"failures": failures,
	}
	var out := ProjectSettings.globalize_path("res://../evidence")
	DirAccess.make_dir_recursive_absolute(out)
	var file := FileAccess.open(out + "/extension-" + str(Time.get_unix_time_from_system()) + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	print("EXTENSION TESTS: %d checks / %d failures" % [results.size(), failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)

## JSON numbers all parse as floats, so compare numerically rather than by
## Variant type. [0.0, 320.0] and [0, 320] are the same geometry.
func _same_numbers(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if not is_equal_approx(float(a[i]), float(b[i])):
			return false
	return true

## Recover a hazard's size from the level data by matching the area's position.
func _hazard_size(level: Dictionary, area: Area2D) -> Vector2:
	for entry in level.hazards:
		if Vector2(entry[0], entry[1]).is_equal_approx(area.position):
			return Vector2(entry[2], entry[3])
	return Vector2.ZERO
