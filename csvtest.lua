function parseRow(r, keys)
    local row = {}
    for match in r:gmatch("[ \t]*([^,]+)") do
        row[#row + 1] = match
    end
    if keys == nil then
        return row
    end
    -- convert indices to keys
    local row_dict = {}
    for j=1,#keys do
        -- print(keys[j])
        row_dict[keys[j]] = row[j]
    end
    return row_dict
end

-- function parseCSV(s)
--     local tab = {}
--     for row in s:gmatch("[^\n]+") do
--         tab[#tab+1] = parseRow(row)
--     end
--     return tab
-- end

function readCSV(filename)
    local lines = {}
    for line in io.lines(filename) do 
        lines[#lines+1] = line
    end
    local result = {}
    keys = parseRow(lines[1])
    for i=2,#lines do
        -- print(lines[i])
        result[#result+1] = parseRow(lines[i], keys)
    end
    return result
end

w = readCSV("waypoints.csv")
print(w[1]["name"])
print(w[1]["x"])
print(w[1]["y"])
print(w[1]["z"])