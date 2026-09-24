extends RefCounted
## Fixed input route through the real level. No position/velocity edits: the
## driver only writes the same test_axis / test_jump_pressed fields that a
## human's A/D and Space would drive, and the level's physics does the rest.
##
## WHY THIS FILE CHANGED FROM THE STARTER
## --------------------------------------
## The starter's driver was a single list of x thresholds, always holding right:
##     jump_marks = [138.0, 292.0, 424.0, 548.0, 712.0]
## That is exactly right for the original 960px course, and those five marks are
## preserved unchanged as the first five marks of HIGH_ROAD below. It cannot
## express section 03's LOW ROAD, which has to run past the terrace's right end
## and then double back LEFT to the flag. So the driver now runs a short list of
## phases, each with a direction, its own jump marks, and an x threshold that
## hands over to the next phase.
##
## The route was extended, not weakened: no assertion was relaxed and the driver
## still has no way to teleport, re-tune, or disable a collision check. A route
## that cannot make a jump simply falls and the test records a failure.

## Hold right the whole way, take the terrace, hop the spikes, reach the flag.
const HIGH_ROAD: Array = [
	{
		"axis": 1.0,
		"jumps": [
			138.0, 292.0, 424.0, 548.0, 712.0,   # original course, unchanged
			946.0,                               # onto The Junction
			1170.0,                              # onto stone 1
			1306.0,                              # onto stone 2
			1442.0,                              # onto the ground run
			1596.0,                              # up onto the Terrace (48px rise)
			1740.0,                              # hop the terrace spike bank
		],
	},
]

## Ignore the terrace, run the safe ground under it, climb out past its far end
## and walk back left to the flag.
const LOW_ROAD: Array = [
	{
		"axis": 1.0,
		"jumps": [
			138.0, 292.0, 424.0, 548.0, 712.0,
			946.0, 1170.0, 1306.0, 1442.0,
			1900.0,                              # up onto the climb-out buttress
		],
		"until": 1996.0,
	},
	{
		"axis": -1.0,
		"jumps": [1958.0],                       # turn round, jump left onto the Terrace
		"until": 1500.0,
	},
]

var phases: Array
var phase_index: int = 0
var mark_index: int = 0
## Total jump marks consumed. Reported by the tests as route coverage.
var next_jump: int = 0

func _init(route: Array = HIGH_ROAD) -> void:
	phases = route

func _past(x: float, target: float, axis: float) -> bool:
	return x >= target if axis > 0.0 else x <= target

func step(player: CharacterBody2D) -> void:
	player.test_control = true
	player.test_jump_held = false
	if phase_index >= phases.size():
		player.test_axis = 0.0
		return
	var phase: Dictionary = phases[phase_index]
	var axis: float = float(phase["axis"])
	player.test_axis = axis
	var marks: Array = phase["jumps"]
	if mark_index < marks.size():
		if _past(player.position.x, float(marks[mark_index]), axis) and player.is_on_floor():
			player.test_jump_pressed = true
			mark_index += 1
			next_jump += 1
	if phase.has("until") and _past(player.position.x, float(phase["until"]), axis):
		phase_index += 1
		mark_index = 0
