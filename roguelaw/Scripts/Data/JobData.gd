class_name JobData
extends Resource

enum Type { BANK, TRAIN, STAGECOACH }
enum Difficulty { EASY, MEDIUM, HARD }

@export var job_type: Type = Type.BANK
@export var difficulty: Difficulty = Difficulty.EASY
@export var payout: int = 0
@export var guard_count: int = 0
@export var heat_gain: int = 0
@export var description: String = ""

static func generate(type: Type, diff: Difficulty) -> JobData:
	var j = JobData.new()
	j.job_type = type
	j.difficulty = diff
	
	match diff:
		Difficulty.EASY:
			j.payout = randi_range(40, 80)
			j.guard_count = randi_range(1, 2)
			j.heat_gain = randi_range(10, 20)
		Difficulty.MEDIUM:
			j.payout = randi_range(80, 150)
			j.guard_count = randi_range(2, 4)
			j.heat_gain = randi_range(20, 35)
		Difficulty.HARD:
			j.payout = randi_range(150, 300)
			j.guard_count = randi_range(4, 7)
			j.heat_gain = randi_range(35, 60)
	
	match type:
		Type.BANK:
			j.description = "Rob the bank. %d guards. Payout ~$%d." % [j.guard_count, j.payout]
		Type.TRAIN:
			j.description = "Hit the train. %d guards. Payout ~$%d." % [j.guard_count, j.payout]
		Type.STAGECOACH:
			j.description = "Hold up the stagecoach. %d guards. Payout ~$%d." % [j.guard_count, j.payout]
	
	return j
