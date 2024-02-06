os.loadAPI("bot_api.lua")
os.loadAPI("pathing_api.lua")

local a = pathing_api.Waypoint.new("a", 0, 0, 0)
local b = pathing_api.Waypoint.new("b", 0, 0, 0)
local c = pathing_api.Waypoint.new("c", 0, 0, 0)
local d = pathing_api.Waypoint.new("d", 0, 0, 0)
local e = pathing_api.Waypoint.new("e", 0, 0, 0)
local f = pathing_api.Waypoint.new("f", 0, 0, 0)
local g = pathing_api.Waypoint.new("g", 0, 0, 0)

a:add_adjacent(b)
a:add_adjacent(c)

b:add_adjacent(d)

c:add_adjacent(b)

d:add_adjacent(e)

e:add_adjacent(f)
e:add_adjacent(c)

f:add_adjacent(g)

local status, path = pathing_api.find_path(a, f)
-- print(status)
path = pathing_api.reverse_table(path)
for i = 1, #path do
    print(path[i]:tostring())
end