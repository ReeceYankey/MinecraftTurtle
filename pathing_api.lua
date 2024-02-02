
-- Waypoint
--  Waypoints function as nodes in the graph
--  self.next is a list of Path which containts the steps to walk the path to next waypoint 

Waypoint = {}
Waypoint.__index = Waypoint

function Waypoint.new(name, x, y, z, next)
    local self = setmetatable({}, Waypoint)
    self.x = x
    self.y = y
    self.z = z
    self.name = name or "no name"
    self.next = next or {}
    return self
end

function Waypoint:addAdjacent(adj, walk)
    -- local b = Path.new(self, adj, walk or {})
    -- table.insert(self.next, b)
    table.insert(self.next, Path.new(self, adj, walk))
    -- table.insert(self.next, adj)
end

function Waypoint:tostring()
    local next_string = "{"
    for i = 1, #self.next do
        if i < #self.next then
            next_string = next_string .. self.next[i].b.name .. ", "
        else
            next_string = next_string .. self.next[i].b.name
        end
    end
    next_string = next_string .. "}"
    return self.name .. ": " .. "x: " .. self.x .. ", y: " .. self.y .. ", z: " .. self.z .. ", next_string: " .. next_string
end

-- Path
--  self.a is first waypoint
--  self.b is second waypoint
--  self.walk is list of Steps to perform the walk from a to b
--   directions are {n, e, s, w, u, d} optionally followed by a number
--  self.walk example: "n2 e4 s w1 u2 d3"

Path = {}
Path.__index = Path

function Path.new(a, b, walk)
    local self = setmetatable({}, Path)
    self.a = a
    self.b = b
    if walk == nil or #walk <= 0 then
        self.walk = Path:basic_walk(a, b)
    else
        self.walk = walk 
    end
    return self
end

function Path:calculate_distance()
    local total_distance = 0
    local i = 1
    while i < #self.walk do
        local direction = self.walk:sub(i, i)
        local times = self.walk:sub(i + 1, i + 1)
        local incr = 3
        if times == " " then
            times = 1
            incr = 2 
        end
        -- print("direction: " .. direction .. ", times: " .. times)
        if direction == "n" or direction == "e" or direction == "s" or direction == "w" or direction == "u" or direction == "d" then
            total_distance = total_distance + times 
        end
        i = i + incr
    end
    return total_distance
end

function Path:perform_walk(bot)
    local i = 1
    while i < #self.walk do
        local direction = self.walk:sub(i, i)
        local times = self.walk:sub(i + 1, i + 1)
        local incr = 3
        if times == nil or times == "" or times == " " or tonumber(times) == nil then
            print("{" .. times .. "}")
            times = 1
            incr = 2 
        end
        print(direction .. " " .. times)
        bot:move(direction, times)
        i = i + incr
    end
end

function Path:basic_walk(a, b)
    if a.x == b.x and a.y == b.y and a.z == b.z then
        return "" 
    elseif a.x ~= b.x and a.y == b.y and a.z == b.z then
        local d = b.x - a.x
        if d < 0 then
            return "w" .. tostring(math.abs(d))
        else
            return "e" .. d
        end
    elseif a.x == b.x and a.y ~= b.y and a.z == b.z then
        local d = b.y - a.y
        if d < 0 then
            return "d" .. tostring(math.abs(d))
        else
            return "u" .. d
        end
    elseif a.x == b.x and a.y == b.y and a.z ~= b.z then
        local d = b.z - a.z
        if d < 0 then
            return "n" .. tostring(math.abs(d))
        else
            return "s" .. d
        end
    else
        print("Not a basic walk")
        error()
    end
end


function Path:tostring()
    return self.a.name .. "->" .. self.b.name .. ", [" .. self.walk .. "]"
end

-- API Functions
