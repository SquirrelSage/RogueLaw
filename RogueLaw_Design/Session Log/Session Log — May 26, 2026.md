
## What I Built
- Travel restricted to connected neighbor towns only
- One job per building per visit (bank and train lock)
- Crew death and wounding on failed jobs
- Heat added on failed jobs (partial)
- Job continue sends back to town instead of map
- Replaced TownData with LocationData and RegionData
- New location types: Town, Camp, Crossroads, Exit Node
- Town archetypes with building pools
- Procedural web map generation
- Exit nodes with their own name pool
- World.gd fully rewritten to use new data layer
- Moved project out of OneDrive into C:/Dev/RogueLaw
- GitHub set up and connected properly
- Obsidian vault created at C:/Dev/RogueLaw

## What I Decided
- Heat and Bounty are two separate systems
- Heat = regional pressure on locations
- Bounty = personal infamy, follows you, is good
- Max heat burns a town permanently — cannot return
- Bounty hunters use heat to pathfind toward player
- Score = total haul. No power win state.
- GTT (Gone to Texas) is the prestige ending
- Prison and Death are the other two endings
- Doctor is a hireable crew member, not a building
- Two of everything first — classes and balance come later
- No tutorial — world teaches through consequences
- Ghosts of previous run characters haunt locations
- Cottonwood Sign is the meta hub between runs
- Legend Points are the meta currency
- Avoid social commentary — stick to spaghetti western tone

## What Broke
- Clicking camp crashed game (town_name reference) — fixed
- World.gd had old current_town_index reference — fixed
- Find and replace town_name → location_name across files
- Map graph sometimes generates disconnected nodes — not fixed yet

## What Needs Fixing Next
- Map connectivity — guarantee all nodes reachable from start
- Heat system has no actual consequences yet
- Bounty system not implemented yet
- Camp and Crossroads have no content
- Sheriff does nothing visible to player
- Gunsmith does nothing
- Region name not displayed anywhere
- No map button from town screen

## Playtest Notes
- Eli Ringo hit $1988 total haul in one session
- Optimal strategy found in 15 minutes — two safecrackers, 
  best horse, note doctor locations
- Game feels like exploration but has no tension
- New location types feel cool — seeing new building 
  names is satisfying
- Ride scene is the most engaging part of the game
- No stakes, no reward, gets repetitive fast
- Heat and Bounty implementation is the critical next step