extends SceneTree
## Measures the REAL jump envelope of the shipped player in the shipped engine,
## so level geometry is designed against observed physics instead of textbook
## arithmetic. Paper math says the apex rise is v^2/2g = 53.33 px; the discrete
## 60 Hz integrator actually produces ~56 px. Level design that trusted the
## paper number would leave ~3 px of unearned margin on every raised landing.
##
## Run: godot --headless --path godot --script res://tools/probe_jump.gd
## Writes: evidence/jump-envelope.json
##
## Reported "max gap" is edge-to-edge between two solids, and accounts for the
## 18 px collider: the player may take off with its centre 9 px past the launch
## edge and lands as soon as its centre is 9 px short of the landing edge.

const Player = preload("res://features/player/player.gd")

const FLOOR_TOP := 368.0
const HALF_WIDTH := 9.0
const RISE_THRESHOLDS: Array[float] = [0.0, 8.0, 16.0, 24.0, 32.0, 40.0, 44.0, 48.0, 52.0, 56.0]

var player: CharacterBody2D
var world: Node2D

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
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
	# One very long flat runway; nothing else in the world to interfere.
	_add_floor(Rect2(0, FLOOR_TOP, 6000, 64))
	player = Player.new()
	world.add_child(player)
	player.reset_at(Vector2(200, FLOOR_TOP))
	player.test_control = true
	player.enabled = true
	await steps(2)

	# Accelerate to the steady-state run speed before launching.
	player.test_axis = 1.0
	await steps(40)
	var run_speed: float = player.velocity.x

	var origin := player.position
	player.test_jump_pressed = true
	var samples: Array = []
	var apex := 0.0
	var airborne_ticks := 0
	for i in range(200):
		await steps(1)
		var dx: float = player.position.x - origin.x
		var rise: float = origin.y - player.position.y
		apex = maxf(apex, rise)
		samples.append({"tick": i + 1, "dx": dx, "rise": rise})
		airborne_ticks = i + 1
		if i > 2 and player.is_on_floor():
			break

	# For each landing height, the furthest the centre can be while still at or
	# above that height. Only the descending side matters for landing, but taking
	# the max over the whole arc is the correct reachability bound.
	var envelope: Array = []
	for threshold in RISE_THRESHOLDS:
		var best_dx := -1.0
		for s in samples:
			if s.rise >= threshold - 0.0001:
				best_dx = maxf(best_dx, s.dx)
		envelope.append({
			"landing_rise_px": threshold,
			"reachable": best_dx >= 0.0,
			"max_centre_travel_px": snappedf(best_dx, 0.01),
			"max_edge_to_edge_gap_px": snappedf(best_dx + HALF_WIDTH * 2.0, 0.01) if best_dx >= 0.0 else -1.0,
		})
		print("rise %5.1f px -> centre travel %7.2f px, max gap %7.2f px%s" % [
			threshold, best_dx, best_dx + HALF_WIDTH * 2.0, "" if best_dx >= 0.0 else "   UNREACHABLE"])

	var jumper_head_clearance: float = apex + 28.0
	print("--- measured apex rise: %.3f px (paper: 53.333)" % apex)
	print("--- airborne ticks: %d (%.3f s)" % [airborne_ticks, airborne_ticks / 60.0])
	print("--- steady run speed: %.3f px/s" % run_speed)
	print("--- a jumping player's HEAD reaches %.3f px above the floor" % jumper_head_clearance)

	var report := {
		"scope": "Measured jump envelope of the unmodified player physics. Flat runway, full run speed, no obstacles.",
		"engine": Engine.get_version_info().string,
		"created_at": Time.get_datetime_string_from_system(true),
		"steady_run_speed_px_s": run_speed,
		"measured_apex_rise_px": apex,
		"paper_apex_rise_px": 53.3333,
		"airborne_ticks": airborne_ticks,
		"collider_height_px": 28.0,
		"jumping_head_reach_px": jumper_head_clearance,
		"envelope": envelope,
		"arc_samples": samples,
	}
	var out := ProjectSettings.globalize_path("res://../evidence")
	DirAccess.make_dir_recursive_absolute(out)
	var file := FileAccess.open(out + "/jump-envelope.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	quit(0)
