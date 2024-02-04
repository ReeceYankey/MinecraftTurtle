Bot = {}
Bot.__index = Bot

-- Compass
--    0
--  3   1
--    2

--  up - 4
--  down - 5

function Bot.new(x, y, z, facing, excluded_slots)
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
    self.excluded_slots = excluded_slots or {16}
    return self
end

-- MOVEMENT -- 

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
        if result == false then
            print("no fuel :(")
            error()
        end
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

-- INVENTORY MANAGEMENT -- 

function Bot:find_slot_of(name, excluded_slots, inventory)
    local maxSlots = 16
    if inventory == nil then
        inventory = turtle
    else
        maxSlots = inventory.size()
    end
    if excluded_slots == nil then
        excluded_slots = {}
    end
    for i = 1, maxSlots do
        local item = inventory.getItemDetail(i)
        if not is_excluded_slot(i, excluded_slots) and item ~= nil and item["name"] == name then
            return i
        end
    end
    return -1
end

function Bot:find_slots_of(name, excluded_slots, inventory)
    local maxSlots = 16
    if inventory == nil then
        inventory = turtle
    else
        maxSlots = inventory.size()
    end
    if excluded_slots == nil then
        excluded_slots = {}
    end
    local found = {}
    for i = 1, maxSlots do
        local item = inventory.getItemDetail(i)
        local is_excluded = is_excluded_slot(i, excluded_slots)
        if not is_excluded and item ~= nil and item["name"] == name then
            table.insert(found, i)
        end
    end
    return found
end

function Bot:place(slot, item_to_check)
    local original_slot = turtle.getSelectedSlot()
    if item_to_check ~= nil then
        local item = turtle.getItemDetail(slot)
        local replace_slot = -1
        if item ~= nil or item["name"] == item_to_check then
            turtle.select(slot)
            turtle.place()
            turtle.select(original_slot)
        end
    else
        turtle.select(slot)
        turtle.place()
        turtle.select(original_slot)
    end
end

function Bot:is_excluded_slot(slot, excluded_slots)
    if  excluded_slots == nil then
        excluded_slots = self.excluded_slots
    end
    for i = 1, #excluded_slots do
        if slot == excluded_slots[i] then
            return true
        end
    end
    return false
end

-- CHEST MANAGEMENT -- 
-- There is no way to take items from a chest by slot, you only can use turtle.suck() >:(
function Bot:push_items(direction, slots, excluded_slots, sleep_if_full)
    if excluded_slots == nil then
        excluded_slots = self.excluded_slots
    end
    if sleep_if_full == nil then
        sleep_if_full = false
    end
    if slots == "all" then
        slots = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
    end
    local original_select = turtle.getSelectedSlot()
    for i = 1, #slots do
        if not is_excluded_slot(slots[i], excluded_slots) then
            local item = turtle.getItemDetail(i)
            if item ~= nil then
                turtle.select(i)
                if sleep_if_full then
                    while not turtle.drop() do
                        print("chest full, sleeping")
                        sleep(5) 
                    end
                else
                    if direction == "f" then
                        turtle.drop()
                    elseif direction == "u" then
                        turtle.dropUp()
                    elseif direction == "d" then
                        turtle.dropDown()
                    else
                        print("invalid drop direction")
                        error()
                    end
                end
                local item_after_drop = turtle.getItemDetail(i)
                local items_left = 0
                if item_after_drop ~= nil then
                    items_left = item_after_drop["count"]
                end
                print("pushed " .. item["count"] - items_left .. " " .. item["name"])
            end
        end
    end
    turtle.select(original_select)
end

function Bot:tostring()
    return "x: " .. tostring(self.x) .. ", y: " .. tostring(self.y) .. ", z: " .. tostring(self.z) .. ", facing: " .. tostring(self.facing)
end