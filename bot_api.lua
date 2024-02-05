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

    -- print(textutils.serialise(excluded_slots))

    for i = 1, maxSlots do
        local item = inventory.getItemDetail(i)
        if item == nil then
            -- print(i .. " {" .. name .. "}" .. "{" .. tostring(item) .. "}")
            -- print(i .. " " .. tostring(self:is_excluded_slot(i, excluded_slots)) .. " " .. tostring(item ~= nil))
        else
            -- print(i .. " {" .. name .. "} " .. "{" .. tostring(item["name"]) .. "}")
            -- print(i .. " " .. tostring(self:is_excluded_slot(i, excluded_slots)) .. " " .. tostring(item ~= nil) .. " " .. item["name"] == name)
        end
        local a = self:is_excluded_slot(i, excluded_slots)
        local b = item ~= nil
        local c = false
        if item ~= nil then
            c = item["name"] == name
        end
        -- print(tostring(a) .. " " .. tostring(b) .. " " .. tostring(c))
        if not self:is_excluded_slot(i, excluded_slots) and item ~= nil and item["name"] == name then
            -- print("true")
            return i
        else
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

    if from_slot < 1 or from_slot > 16 or to_slot < 1 or to_slot > 16 then
        print("transfer fail " .. tostring(from_slot) .. " " .. tostring(to_slot))
        return false 
    end

    local from_item = turtle.getItemDetail(from_slot)
    local to_item = turtle.getItemDetail(to_slot)

    if from_item == nil then -- No item to transfer
        print("transfer fail " .. tostring(from_slot) .. " " .. tostring(to_slot))
        return false
    end
    
    local original_select = turtle.getSelectedSlot()
    if to_item == nil then
        turtle.select(from_slot)    
        turtle.transferTo(to_slot)
        print("transfer " .. tostring(from_slot) .. " " .. tostring(to_slot))
        return true -- to_slot is empty so can transfer
    elseif from_item ~= nil and to_item ~= nil and from_item["name"] == to_item["name"] then
        turtle.select(from_slot)
        turtle.transferTo(to_slot)
        print("transfer " .. tostring(from_slot) .. " " .. tostring(to_slot))
        return true -- items are same and can stack
    elseif from_item ~= nil and to_item ~= nil and from_item["name"] ~= to_item["name"] then
        print("to_slot has item")
        local empty_slot = self:find_empty_slot()
        if empty_slot ~= -1 then
            turtle.select(to_slot)
            turtle.transferTo(empty_slot)
            turtle.select(from_slot)
            turtle.transferTo(to_slot)
            print("transfer " .. tostring(from_slot) .. " " .. tostring(to_slot))
            return true -- found empty slot
        else
            print("transfer fail " .. tostring(from_slot) .. " " .. tostring(to_slot))
            return false -- couldn't find empty slot to replace
        end
    else
        print("transfer fail " .. tostring(from_slot) .. " " .. tostring(to_slot))
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
        if item ~= nil and item["name"] == item_to_check then
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

-- suck
-- Sucks items from world or an inventory
-- There is no way to take items from a chest by slot, you only can use turtle.suck() >:(
-- direction <string> {"f", "u", "d"}
-- [count] <integer> amount to suck, if nil, then will default to stack
-- return
--    sucked <bool>
--    reason <string>
function Bot:suck(direction, count)
    local original_select = turtle.getSelectedSlot()
    turtle.select(1)
    if direction == "f" then
        return turtle.suck(count)
    elseif direction == "d" then
        return turtle.suckDown(count)
    elseif direction == "u" then
        return turtle.suckUp(count)
    end
    turtle.select(original_select)
end

function Bot:push_items(direction, slots, excluded_slots)
    if excluded_slots == nil then
        excluded_slots = self.excluded_slots
    end
    if sleep_if_full == nil then
        sleep_if_full = false
    end
    if slots == "all" then
        slots = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
    end

    print("push_items " .. direction .. " ".. self:table_to_string(slots))

    local original_select = turtle.getSelectedSlot()
    for i = 1, #slots do
        assert(slots[i] > 0 and slots[i] < 17)
        if not self:is_excluded_slot(slots[i], excluded_slots) then
            local item = turtle.getItemDetail(i)
            if item ~= nil then
                turtle.select(slots[i])
                if sleep_if_full then
                    local item_dropped = false
                    while not item_dropped do
                        if direction == "f" then
                            item_dropped = turtle.drop()
                        elseif direction == "u" then
                            item_dropped = turtle.dropUp()
                        elseif direction == "d" then
                            item_dropped = turtle.dropDown()
                        else
                            print("invalid drop direction")
                            error()
                        end
                    end
                else
                    if direction == "f" then
                        item_dropped = turtle.drop()
                    elseif direction == "u" then
                        item_dropped = turtle.dropUp()
                    elseif direction == "d" then
                        item_dropped = turtle.dropDown()
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
                print("pushed slot " .. i  .. " ".. item["count"] - items_left .. " " .. item["name"])
            end
        end
    end
    turtle.select(original_select)
end

-- negate_table
-- removes values from original table based on negate table
-- original <table {generic}>
-- negate <table {generic}>
-- return table of removed values
function Bot:negate_table(original, negate)
    local result = {}
    for i = 1, #negate do
        for c = 1, #original do
            if original[c] ~= negate[i] then
                table.insert(result, original[c])
            end
        end
    end
    return result
end

function Bot:table_to_string(table)
    local table_string = "{"
    for i = 1, #table do
        if i < #table  then
            table_string = table_string .. tostring(table[i]) .. ", "
        else
            table_string = table_string .. tostring(table[i])
        end
    end
    table_string = table_string .. "}"
    return table_string
end

-- tostring
function Bot:tostring()
    return "x: " .. tostring(self.x) .. ", y: " .. tostring(self.y) .. ", z: " .. tostring(self.z) .. ", facing: " .. tostring(self.facing)
end