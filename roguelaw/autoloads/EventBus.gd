extends Node

# Run signals
signal run_started
signal run_ended(cause: String)

# Player signals
signal money_changed(new_amount: int)
signal health_changed(new_amount: int)

# Heat signals
signal heat_changed(new_amount: int)
signal bounty_hunter_spawned

# Horse signals
signal horse_changed
signal horse_died

# Crew signals
signal crew_member_added(member)
signal crew_member_died(member)

# Town signals
signal town_entered(town_data)
signal building_entered(building_type: String)

# Job signals
signal job_started(job_data)
signal job_completed(success: bool, payout: int)

# Travel signals
signal travel_started(destination)
signal travel_event_triggered(event_data)
