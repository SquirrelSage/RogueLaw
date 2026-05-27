extends Node

enum State {
	MAIN_MENU,
	MAP,
	TOWN,
	JOB,
	RIDE,
	DEATH_SCREEN
}

var current_state: State = State.MAIN_MENU

# Scene paths
const SCENES = {
	State.MAIN_MENU: "res://Scenes/MainMenu.tscn",
	State.MAP: "res://Scenes/World.tscn",
	State.TOWN: "res://Scenes/Town.tscn",
	State.JOB: "res://Scenes/Job.tscn",
	State.RIDE: "res://Scenes/Ride/Ride.tscn",
	State.DEATH_SCREEN: "res://Scenes/UI.tscn"
}

func _ready() -> void:
	#change_state(State.MAIN_MENU)
	pass


func change_state(new_state: State) -> void:
	current_state = new_state
	_load_scene(new_state)

func _load_scene(state: State) -> void:
	var path = SCENES.get(state, "")
	if path == "":
		push_error("No scene path for state: " + str(state))
		return
	get_tree().change_scene_to_file.call_deferred(path)

func start_game() -> void:
	RunData.start_new_run(_generate_name())
	change_state(State.MAP)

func trigger_death(cause: String) -> void:
	RunData.end_run(cause)
	change_state(State.DEATH_SCREEN)

func _generate_name() -> String:
	var first_names = ["Cole", "Hank", "Eli", "Jesse", "Virgil", "Dutch", "Clay", "Wade"]
	var last_names = ["Dalton", "McCready", "Harlow", "Boone", "Cain", "Ringo", "Ford", "Hayes"]
	return first_names.pick_random() + " " + last_names.pick_random()
