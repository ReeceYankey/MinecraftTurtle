os.loadAPI("bot_api.lua")
os.loadAPI("pathing_api.lua")

local homeN = pathing_api.Waypoint.new("homeN", 35, 63, 88)
local homeS = pathing_api.Waypoint.new("homeS", 34, 63, 88)

local mainCrossW = pathing_api.Waypoint.new("mainCrossW", 35, 63, 75)
local mainCrossE = pathing_api.Waypoint.new("mainCrossE", 34, 63, 76)

local bridgeW1 = pathing_api.Waypoint.new("bridgeW1", 30, 63, 75)
local bridgeW2 = pathing_api.Waypoint.new("bridgeW2", 23, 63, 75)
local bridgeE1 = pathing_api.Waypoint.new("bridgeE1", 23, 63, 76)
local bridgeE2 = pathing_api.Waypoint.new("bridgeE2", 30, 63, 76)

local westStairsW1 = pathing_api.Waypoint.new("westStairsW1", 14, 63, 78)
local westStairsW2 = pathing_api.Waypoint.new("westStairsW2", 5, 71, 78)
local westStairsE1 = pathing_api.Waypoint.new("westStairsW1", 5, 71, 79)
local westStairsE2 = pathing_api.Waypoint.new("westStairsW2", 14, 63, 79)

homeN:add_adjacent(mainCrossW)
mainCrossE:add_adjacent(homeS)
homeS:add_adjacent(homeN)

mainCrossW:add_adjacent(bridgeW1)
bridgeE2:add_adjacent(mainCrossE)
mainCrossW:add_adjacent(mainCrossE, {"w", "s"})
mainCrossE:add_adjacent(mainCrossW, {"e", "n"})

bridgeW1:add_adjacent(bridgeW2, {"u", "w", 7, "d"})
bridgeE1:add_adjacent(bridgeE2, {"u", "e", 7, "d"})

bridgeW2:add_adjacent(westStairsW1, {"w", 3, "s", "w", 5, "s", 2, "w"})
westStairsE2:add_adjacent(bridgeE1, {"e", 2, "n", 2, "e", 5, "n", "e", 2})

westStairsW1:add_adjacent(westStairsE2)

-- print(homeN:tostring())
-- print(homeS:tostring())
-- print(mainCrossW:tostring())
-- print(mainCrossE:tostring())

local bot = bot_api.Bot.new(35, 63, 88, "n")

local status, path = pathing_api.find_path(homeN, homeS)
print(status)
for i = 1, #path do
    print(path[i]:tostring())
    path[i]:perform_walk(bot)
end

-- local status, path = pathing_api.find_path(westStairsW1, homeN)
-- print(status)
-- for i = 1, #path do
--     print(path[i]:tostring())
--     path[i]:perform_walk(bot)
-- end

-- bot:face_cardinal("n")
