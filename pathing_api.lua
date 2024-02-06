-- os.loadAPI("queue.lua")

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

function Waypoint:add_adjacent(adj, walk)
    table.insert(self.next, Path.new(self, adj, walk))
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
    return self.name .. ": " .. "x: " .. self.x .. ", y: " .. self.y .. ", z: " .. self.z .. ", next: " .. next_string
end

-- Path
--  self.a is first waypoint
--  self.b is second waypoint
--  self.walk is list of Steps to perform the walk from a to b
--  directions are {n, e, s, w, u, d} optionally followed by a number
--  self.walk example: {n, e, s, 2, w}. This will have "n" "e" and "w"
--  be one step, while s, 2 is two steps

Path = {}
Path.__index = Path

function Path.new(a, b, walk)
    local self = setmetatable({}, Path)
    self.a = a
    self.b = b
    self.walk = walk or self:basic_walk(a, b)
    return self
end

-- calculate_distance
-- return <integer> distance
function Path:calculate_distance()
    local total_distance = 0
    local i = 1
    while i <= #self.walk do
        local direction = self.walk[i]
        local times = self.walk[i + 1]
        local incr = 2
        if self.walk[i + 1] == nil or type(self.walk[i + 1]) == "string" then
            times = 1
            incr = 1
        end
        if direction == "n" or direction == "e" or direction == "s" or direction == "w" or direction == "u" or direction == "d" then
            total_distance = total_distance + times
        end
        i = i + incr
    end
    return total_distance
end

-- perform_walk
-- Performs the self.walk of path
-- param bot <Bot> bot to perform walk with
function Path:perform_walk(bot)
    local i = 1
    while i <= #self.walk do
        local direction = self.walk[i]
        local times = self.walk[i + 1]
        local incr = 2
        if self.walk[i + 1] == nil or type(self.walk[i + 1]) == "string" then
            times = 1
            incr = 1
        end
        bot:move(direction, times)
        i = i + incr
    end
end

-- basic_walk
-- Given path a and path b, verify if a straight line in one
-- axis and then return the bot instructions to walk from a to b
-- param a <Waypoint>
-- param b <Waypoint>
-- return <table {[<string>, <integer]}> instructions to walk
function Path:basic_walk(a, b)
    if a.x == b.x and a.y == b.y and a.z == b.z then
        return {} 
    elseif a.x ~= b.x and a.y == b.y and a.z == b.z then
        local d = b.x - a.x
        if d < 0 then
            return {"w", math.abs(d)}
        else
            return {"e", d}
        end
    elseif a.x == b.x and a.y ~= b.y and a.z == b.z then
        local d = b.y - a.y
        if d < 0 then
            return {"d", math.abs(d)}
        else
            return {"u", d}
        end
    elseif a.x == b.x and a.y == b.y and a.z ~= b.z then
        local d = b.z - a.z
        if d < 0 then
            return {"n", math.abs(d)}
        else
            return {"s", d}
        end
    else
        print("Not a basic walk: " .. self:tostring())
        error()
    end
end

-- tostring
function Path:tostring()
    local walk_string = "{"
    for i = 1, #self.walk do
        if i < #self.walk then
            walk_string = walk_string .. tostring(self.walk[i]) .. ", "
        else
            walk_string = walk_string .. tostring(self.walk[i])
        end
    end
    walk_string = walk_string .. "}"
    local a_name = "nil"
    local b_name = "nil"
    if self.a ~= nil then
        a_name = self.a.name
    end
    if self.b ~= nil then
        b_name = self.b.name
    end
    return a_name .. "->" .. b_name .. ", " .. walk_string
end

-- API Functions

-- find_path
-- BFS (DFS right now) to find path from start to dest
-- param start <Waypoint> start waypoint
-- param dest <Waypoint> destination waypoint
-- return <bool> status,
--        <table {<Path>}> list of paths from start to dest
function find_path(start, dest)
    local queue = {}
    local visited = {}

    local parents = {}

    -- encapsulate start waypoint with a path so function can properly work
    local starter = Path.new(nil, start, {})
    table.insert(queue, starter)

    while #queue > 0 do
        local cur_path = table.remove(queue) 
        -- print(cur_path:tostring())
        local cur_waypoint = cur_path.b
        if cur_waypoint == dest then
            -- print("\tfound")
            table.insert(parents, {cur_waypoint, cur_path})
            return true, backtrace(parents, start, dest)
        end
        if index_of(visited, cur_waypoint) == -1 then
            -- print("checking " .. cur_waypoint:tostring())
            table.insert(visited, cur_waypoint)
            for i = 1, #cur_waypoint.next do
                if i == 1 then
                    table.insert(parents, {cur_waypoint, cur_path})
                end
                table.insert(queue, cur_waypoint.next[i])
            end
        else
            -- print("\tvisited")
        end
    end
    return false
end

-- backtrace
-- given parents of waypoints, reconstruct path from start to dest
-- param parents <table {{<Waypoint>, <Path>}}
-- param start <Waypoint>
-- param dest <Waypoint>
-- return <table {Path} list of paths going from start to dest
function backtrace(parents, start, dest)
    waypoints = {dest}
    path = {}
    local i = 1
    while i < 20 and waypoints[#waypoints] ~= start do
        local parent = {}
        for p = 1, #parents do
            print(parents[p][1].name .. " " .. waypoints[#waypoints].name)
            if parents[p][1] == waypoints[#waypoints] then 
                parent = parents[p]
            end
        end
        table.insert(waypoints, parent[2].a)
        table.insert(path, parent[2])
        i = i + 1
    end
    return reverse_table(path)
end

-- reverse_table
function reverse_table(t)
    local reverse = {}
    for i = #t, 1, -1 do
        table.insert(reverse, t[i]) 
    end
    return reverse
end

-- index_of
function index_of(table, value)
    for i = 1, #table do
        if table[i] == value then
            return i
        end
    end  
    return -1
end