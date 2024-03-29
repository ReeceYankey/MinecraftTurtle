os.loadAPI("bot_api.lua")
os.loadAPI("pathing_api.lua")

local bot = bot_api.Bot.new(34, 74, 88, "w", {15, 16})

local a = pathing_api.Waypoint.new("tree1", 37, 74, 88)
local b = pathing_api.Waypoint.new("tree2", 40, 74, 88)
local c = pathing_api.Waypoint.new("tree3", 43, 74, 88)
local d = pathing_api.Waypoint.new("tree4", 46, 74, 88)
local e = pathing_api.Waypoint.new("tree5", 46, 74, 86)
local f = pathing_api.Waypoint.new("tree6", 43, 74, 86)
local g = pathing_api.Waypoint.new("tree7", 40, 74, 86)
local h = pathing_api.Waypoint.new("tree8", 37, 74, 86)

local home = pathing_api.Waypoint.new("home", 34, 74, 88)
local waypoints = {a, b, c, d, e, f, g, h, home}

local paths = {
    pathing_api.Path.new(home, a),
    pathing_api.Path.new(a, b),
    pathing_api.Path.new(b, c),
    pathing_api.Path.new(c, d),
    pathing_api.Path.new(d, e),
    pathing_api.Path.new(e, f),
    pathing_api.Path.new(f, g),
    pathing_api.Path.new(g, h),
    pathing_api.Path.new(h, a),
    pathing_api.Path.new(a, home)
}

function home_unload_items()
    print("home base")
    bot:face_cardinal("w")
    bot:move("s", 2)
    bot:move("d")
    bot:face_cardinal("s")
    local sucked, status = bot:suck("d")
    -- "No items to take"
    -- "No space for items"
    local loop = true
    while loop do
        if status == "No space for items" then
            print("no space for items")
            bot:move("u")
            bot:move("n", 2)
            print("found_spruce")
            local a = bot:find_slots_of("minecraft:spruce_log")
            bot:push_items("d", a)
            bot:transfer_to(bot:find_slot_of("minecraft:spruce_sapling"), 15)
            bot:move("s", 2)
            bot:move("d")
            bot:push_items("f", "all")
        elseif status == "No items to take" then
            print("no items to take")
            bot:move("u")
            bot:move("n", 2)
            local a = bot:find_slots_of("minecraft:spruce_log")
            bot:push_items("d", a)
            bot:transfer_to(bot:find_slot_of("minecraft:spruce_sapling"), 15)
            bot:move("s", 2)
            bot:move("d")
            bot:push_items("f", "all")
            loop = false
        end
        sucked, status = bot:suck("d")
    end
    -- print("ending item management")
    bot:move("u")
    bot:move("n", 2)
    bot:face_cardinal("w")
end

function check_and_mine_tree()
    if bot.z == 88 then
        bot:face_cardinal("s")
    elseif bot.z == 86 then
        bot:face_cardinal("n")
    else
        print("Weird Z Axis")
        error()
    end
    local has_block, info = turtle.inspect()
    if has_block and info["name"] == "minecraft:spruce_log" then
        print("mining tree")

        turtle.dig() 
        bot:move("f")

        has_block = turtle.inspectUp()
        while has_block do
            turtle.digUp()
            bot:move("u")
            has_block = turtle.inspectUp()
        end

        has_block = turtle.inspectDown()
        while not has_block do
            bot:move("d")
            has_block = turtle.inspectDown()
        end
        -- for i = 1, 4 do
        --     bot:turn("r")
        --     turtle.suck()
        -- end
        bot:turn("a")
        bot:move("f")
        bot:turn("a")
        bot:place(15, "minecraft:spruce_sapling")
    elseif info["name"] ~= "minecraft:spruce_sapling" 
    and info["name"] ~= "minecraft:spruce_log" then
        print("planting sapling")
        turtle.dig()
        bot:place(15, "minecraft:spruce_sapling")
    else
        print("checking_tree")
    end
end

-- home_unload_items()

while true do
    for i, v in ipairs(paths) do
        print(v:tostring())
        v:perform_walk(bot)
        if v.b.name == "home" then
            home_unload_items()
            print("sleeping zZZZZzz")
            sleep(300)
        else
            check_and_mine_tree()
        end
    end
end

