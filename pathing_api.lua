
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
--   directions are {n, e, s, w, u, d} optionally followed by a number
--  self.walk example: {n, e, s, 2, w}

Path = {}
Path.__index = Path

function Path.new(a, b, walk)
    local self = setmetatable({}, Path)
    self.a = a
    self.b = b
    self.walk = walk or self:basic_walk(a, b)
    return self
end

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

function find_path(start, dest)
    local queue = {}
    local visited = {}

    local parents = {}

    -- encapsulate start waypoint with a path so function can properly work
    local starter = Path.new(nil, start, {})
    table.insert(queue, starter)

    while #queue > 0 do
        local cur_path = table.remove(queue) 
        print(cur_path:tostring())
        local cur_waypoint = cur_path.b
        if cur_waypoint == dest then
            print("\tfound")
            table.insert(parents, {cur_waypoint, cur_path})
            return true, backtrace(parents, start, dest)
        end
        if index_of(visited, cur_waypoint) == -1 then
            print("checking " .. cur_waypoint.name)
            table.insert(visited, cur_waypoint)
            for i = 1, #cur_waypoint.next do
                table.insert(parents, {cur_waypoint, cur_path})
                table.insert(queue, cur_waypoint.next[i])
            end
        else
            print("\tvisited")
        end
    end
    return false
end

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
    return path
end

function reverse_table(t)
    local reverse = {}
    for i = #t, 1, -1 do
        table.insert(reverse, t[i]) 
    end
    return reverse
end

function index_of(table, value)
    for i = 1, #table do
        if table[i] == value then
            return i
        end
    end  
    return -1
end