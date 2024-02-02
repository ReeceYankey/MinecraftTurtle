os.loadAPI("bot_api")
os.loadAPI("pathing_api")

local a = pathing_api.Waypoint.new("a", 35, 63, 85)
local b = pathing_api.Waypoint.new("b", 35, 63, 79)
local c = pathing_api.Waypoint.new("c", 33, 63, 80)
local d = pathing_api.Waypoint.new("d", 33, 63, 83)

a:addAdjacent(b)
b:addAdjacent(c, "w s w")
c:addAdjacent(d)
d:addAdjacent(a, "e s2 e")

local bot = bot_api.Bot.new(a.x, a.y, a.z, 0)

local p = {a.next[1], b.next[1], c.next[1], d.next[1]}
-- for i = 1, 2 do
--     print(p[i]:tostring())
--     p[i]:perform_walk(bot)
-- end
for i, v in ipairs(p) do
    print(v:tostring())
    v:perform_walk(bot)
end
bot:face_cardinal("n")