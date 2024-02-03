Bot = {}
Bot.__index = Bot

-- Compass
--    0
--  3   1
--    2

--  up - 4
--  down - 5

function Bot.new(x, y, z, facing)
    local self = setmetatable({}, Bot)
    if facing == "n" then
        self.facing = 0
    elseif facing == "e" then
        self.facing = 1
    elseif facing == "s" then
        self.facing = 2
    elseif facing == "w" then
        self.facing = 3
    else
        self.facing = facing or 0
    end
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    return self
end

function Bot:face_cardinal(cardinal)
    if type(cardinal) == "string" then
        cardinal = self:cardinal_to_num(cardinal)
    end

    if (self.facing + 1) % 4 == cardinal then
        self:turn("r")
    elseif (self.facing -1) % 4 == cardinal then
        self:turn("l")
    elseif (self.facing) ~= cardinal then
        self:turn("a")
    end
    assert(self.facing == cardinal)
end

function Bot:move(direction, num)
    if num == nil then
        num = 1
    end
    print(direction .. " " .. num)
    if direction == "u" then
        for i = 1, num do
            self:refuelToLevel(1)
            assert(turtle.up())
            self.y = self.y + 1 
        end
    elseif direction == "d" then
        for i = 1, num do
            self:refuelToLevel(1)
            assert(turtle.down())
            self.y = self.y - 1 
        end
    elseif direction == "f" then
        for i = 1, num do
            self:refuelToLevel(1)
            assert(turtle.forward())
            if self.facing == 0 then
                self.z = self.z - 1
            elseif self.facing == 1 then
                self.x = self.x + 1
            elseif self.facing == 2 then
                self.z = self.z + 1
            else 
                self.x = self.x - 1
            end
        end
    else
        self:face_cardinal(direction)
        for i = 1, num do
            self:refuelToLevel(1)
            assert(turtle.forward())
            if self.facing == 0 then
                self.z = self.z - 1
            elseif self.facing == 1 then
                self.x = self.x + 1
            elseif self.facing == 2 then
                self.z = self.z + 1
            else 
                self.x = self.x - 1
            end
        end
    end
end

function Bot:turn(direction, num)
    if num == nil then
        num = 1
    end
    for i = 1, num do
        if direction == "r" then
            assert(turtle.turnRight())
            self.facing = (self.facing + 1) % 4
        elseif direction == "l" then
            assert(turtle.turnLeft())
            self.facing = (self.facing - 1) % 4
        elseif direction == "a" then
            assert(turtle.turnRight())
            assert(turtle.turnRight())
            self.facing = (self.facing + 2) % 4
        else
            print("Invalid direction")
            error()
        end
    end
end

function Bot:refuelToLevel(level)
    cur_select = turtle.getSelectedSlot()
    while turtle.getFuelLevel() < level do
        turtle.select(16)
        result, err_status = turtle.refuel(level - turtle.getFuelLevel())
        assert(result)
    end
    assert(turtle.select(cur_select))
    return true
end

function Bot:cardinal_to_num(cardinal)
    if cardinal == "n"  then
        return 0
    elseif cardinal == "e" then
        return 1
    elseif cardinal == "s" then
        return 2
    elseif cardinal == "w" then
        return 3
    else
        print("Invalid cardinal")
        error()
    end
end

function Bot:tostring()
    return "x: " .. self.x .. ", y: " .. self.y .. ", z: " .. self.z .. ", facing: " .. self.facing
end