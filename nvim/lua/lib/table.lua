---
-- weird table funcs i actually needed pretty often
---

local table = table
local M = {}

function M.filter_inplace(tbl, func)
    -- stolen from here https://stackoverflow.com/questions/49709998
    local new_index = 1
    local size_orig = #tbl
    for old_index, v in ipairs(tbl) do
        if func(v, old_index) then
            tbl[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do tbl[i] = nil end
end

function M.find(tbl, func)
    for i, val in pairs(tbl) do
        if func(val) then
            return i
        end
    end
    return nil
end

function M.find_item(tbl, item)
    return M.find(tbl, function (val)
        return val == item
    end)
end

--- insert new item on index 1 and delete if exists 
---@param tbl table
---@param item any
---@param max_index number? Delete last item in case len > max_index
---@param pre_remove function? Function to execute on item before deleting it
function M.push_or_move_up(tbl, item, max_index, pre_remove)
    local old_index = M.find_item(tbl, item)
    if old_index then
        table.remove(tbl, old_index)
    end
    table.insert(tbl, 1, item)
    if max_index and #tbl > max_index then
        if pre_remove then
            pre_remove(tbl[#tbl])
        end
        table.remove(tbl, #tbl)
    end
end

--- return max value of func over items in tbl, func has to return an integer
---@param tbl table
---@param func function
---@return number return value of the function
function M.max(tbl, func)
    local max = 0
    for _, item in pairs(tbl) do
        if func(item) > max then
            max = func(item)
        end
    end
    return max
end

--- select property ID of each item in TBL
---@param tbl table
---@param id string
---@return table
function M.select(tbl, id)
    local ret = {}
    for _, itm in pairs(tbl) do
        ret[#ret+1] = itm[id]
    end
    return ret
end

--- map func return val on each item in tbl
---@param tbl table
---@param func function
--- function has to take one argument, which is the item in the table
--- constructs and returns a new table
---@return table
function M.map(tbl, func)
    local ret = {}
    for i, x in pairs(tbl) do
        ret[i] = func(x)
    end
    return ret
end

return M
