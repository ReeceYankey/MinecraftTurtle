Bot = {}
Bot.__index = Bot

-- Compass
--    0
--  3   1
--    2

function Bot.new(x, y, z, facing)
    local self = setmetatable({}, Bot)
    self.facing = facing or 0
    self.x = x
    self.y = y
    self.z = z
    return self
end

function Bot:face_cardinal(cardinal)
    if type(cardinal) == "string" then
        cardinal = self:cardinal_to_num(cardinal)
    end
    while self.facing ~= cardinal do
        self:turn("r")
        -- print("facing: " .. self.facing)
    end
end

function Bot:move(cardinal, num)
    self:face_cardinal(cardinal)
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
        -- print(self:tostring())
        -- print(num)
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
            self.facing = (self.facing + 1) % 4
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