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
    -- Convert facing string to number
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

-- face_cardinal
-- turn bot to face cardinal direction
-- cardinal <string> {"n", "e", "s", "w"}
function Bot:face_cardinal(cardinal)
    -- check cardinal for string and convert if so
    if type(cardinal) == "string" then
        cardinal = self:cardinal_to_num(cardinal)
    end

    -- turn robot to proper cardinal
    if (self.facing + 1) % 4 == cardinal then
        self:turn("r")
    elseif (self.facing -1) % 4 == cardinal then
        self:turn("l")
    elseif (self.facing) ~= cardinal then
        self:turn("a")
    end
    assert(self.facing == cardinal)
end

-- move
-- move bot in direction
-- direction <string> {"u", "d", "f", "n", "e", "s", "w"}
-- [num] <integer>, if num is nil, then num = 1
function Bot:move(direction, num)
    if num == nil then -- User inputs nil num which means move only once
        num = 1
    end
    print(direction .. " " .. num)
    if direction == "u" then -- move up
        for i = 1, num do
            self:refuel_to_level(1)
            assert(turtle.up())
            self.y = self.y + 1 
        end
    elseif direction == "d" then -- move down
        for i = 1, num do
            self:refuel_to_level(1)
            assert(turtle.down())
            self.y = self.y - 1 
        end
    elseif direction == "f" then -- move forward
        for i = 1, num do
            self:refuel_to_level(1)
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
    else -- move towards cardinal
        self:face_cardinal(direction)
        for i = 1, num do
            self:refuel_to_level(1)
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

-- turn
-- turn bot in direction
-- direction <string> {"r", "l", "a"}
-- [num] <integer> number of times, if num = nil then num = 1
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

-- refuel_to_level
-- refuel turtle to specified fuel level
-- level <integer>
-- return <bool> successful refuel
function Bot:refuel_to_level(level)
    cur_select = turtle.getSelectedSlot()
    while turtle.getFuelLevel() < level do
        turtle.select(16)
        result, err_status = turtle.refuel(level - turtle.getFuelLevel())
        if result == false then
            print("no fuel :(")
            error()
        end
    end
    turtle.select(cur_select)
    return true
end

-- cardinal_to_num
-- convert <string> cardinal to <integer> cardinal
-- cardinal <string> {"n", "e", "s", "w"}
-- return <integer> {0, 1, 2, 3}
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

-- find_slot_of
-- find first slot
-- name <string> item name to search
-- excluded_slots <table {integer}> slots to exclude
-- inventory <obj> inventory to search, if nil, then inventory = turtle
function Bot:find_slot_of(name, excluded_slots, inventory)
    local maxSlots = 16

    if inventory == nil then
        inventory = turtle
        if excluded_slots == nil then
            excluded_slots = self.excluded_slots
        end
    else
        maxSlots = inventory.size()
        if excluded_slots == nil then
            excluded_slots = {}
        end
    end

    for i = 1, maxSlots do
        local item = inventory.getItemDetail(i)
        if not self:is_excluded_slot(i, excluded_slots) and item ~= nil and item["name"] == name then
            return i
        end
    end

    return -1
end

-- find_slot_of
-- find all slots
-- name <string> item name to search
-- excluded_slots <table {integer}> slots to exclude
-- inventory <obj> inventory to search, if nil, then inventory = turtle
function Bot:find_slots_of(name, excluded_slots, inventory)
    local maxSlots = 16

    if inventory == nil then
        inventory = turtle
        if excluded_slots == nil then
            excluded_slots = self.excluded_slots
        end
    else
        maxSlots = inventory.size()
        if excluded_slots == nil then
            excluded_slots = {}
        end
    end

    local found = {}
    for i = 1, maxSlots do
        local item = inventory.getItemDetail(i)
        if not self:is_excluded_slot(i, excluded_slots) 
        and item ~= nil 
        and item["name"] == name then
            table.insert(found, i)
        end
    end

    return found
end

-- find_empty_slot
-- find empty slot
-- excluded_slots <table {integer}> slots to exclude
-- inventory <obj> inventory to search, if nil, then inventory = turtle
function Bot:find_empty_slot(excluded_slots, inventory)
    local maxSlots = 16

    if inventory == nil then
        inventory = turtle
        if excluded_slots == nil then
            excluded_slots = self.excluded_slots
        end
    else
        maxSlots = inventory.size()
        if excluded_slots == nil then
            excluded_slots = {}
        end
    end

    for i = 1, maxSlots do
        local item = inventory.getItemDetail(i)
        if not self:is_excluded_slot(i, excluded_slots) and item == nil then
            return i
        end
    end
    
    return -1
end

-- find_empty_slot
-- find all empty slots
-- excluded_slots <table {integer}> slots to exclude
-- inventory <obj> inventory to search, if nil, then inventory = turtle
function Bot:find_empty_slots(excluded_slots, inventory)
    local maxSlots = 16

    if inventory == nil then
        inventory = turtle
        if excluded_slots == nil then
            excluded_slots = self.excluded_slots
        end
    else
        maxSlots = inventory.size()
        if excluded_slots == nil then
            excluded_slots = {}
        end
    end

    local found = {}
    for i = 1, maxSlots do
        local item = inventory.getItemDetail(i)
        if not self:is_excluded_slot(i, excluded_slots) and item == nil then
            table.insert(found, i)
        end
    end

    return found
end

-- transfer_to
-- transfer from_slot to to_slot
-- from_slot <integer> 
-- to_slot <integer>
-- return <bool> success
function Bot:transfer_to(from_slot, to_slot)
    local from_item = turtle.getItemDetail(from_slot)
    local to_item = turtle.getItemDetail(to_slot)

    if fromItem == nil then -- No item to transfer
        return false
    end
    
    local original_select = turtle.getSelectedSlot()
    if to_item == nil then
        turtle.select(from_slot)    
        turtle.transfer_to(to_slot)
        return true -- to_slot is empty so can transfer
    elseif from_item ~= nil and to_item ~= nil and from_item["name"] == to_item["name"] then
        turtle.select(from_slot)
        turtle.transfer_to(to_slot)
        return true -- items are same and can stack
    elseif from_item ~= nil and to_item ~= nil and from_item["name"] ~= to_item["name"] then
        local empty_slot = bot:find_empty_slot()
        if empty_slot ~= -1 then
            turtle.select(to_slot)
            turtle.transfer_to(empty_slot)
            turtle.select(from_slot)
            turtle.transfer_to(to_slot)
            return true -- found empty slot
        else
            return false -- couldn't find empty slot to replace
        end
    else
        return false -- from_slot empty
    end
end

-- place
-- place block
-- slot <integer> slot to select and place
-- item_to_check <string> item name to verify before placing
function Bot:place(slot, item_to_check)
    local original_slot = turtle.getSelectedSlot()
    if item_to_check ~= nil then
        local item = turtle.getItemDetail(slot)
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

-- is_excluded_slot
-- check if slot is excluded slot
-- slot <integer> slot to check if excluded
-- excluded_slots <table {integer} excluded slots to compare to
-- return if slot is excluded
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
        if not self:is_excluded_slot(slots[i], excluded_slots) then
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

-- tostring
function Bot:tostring()
    return "x: " .. tostring(self.x) .. ", y: " .. tostring(self.y) .. ", z: " .. tostring(self.z) .. ", facing: " .. tostring(self.facing)
end