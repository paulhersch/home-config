local a = vim.api

local m = {}
m.__props = {}
m.buffers = {}

local function create_buf()
    m.buf = a.nvim_create_buf(false, false)
    a.nvim_buf_set_option(m.buf, 'filetype', 'bffrmgr')
end

local function fill_buf()
    local lines = {}
    m.width = 80
    -- this is a very horrible design
    -- i am basically setting the function only if i want to create extmarks for highlighting
    local add_hl = function() end
    table.insert(lines, "")
    if #m.buffers == 0 then
        table.insert(lines, "  Setup not run, or no textbuffers opened  ")
    else
        local buf_cnt = #m.buffers
        for i=buf_cnt-1,1,-1 do
            local b = m.buffers[i]
            local entry_index = buf_cnt - i
            local line = "  " .. m.__props.keys.sub(m.__props.keys, entry_index, entry_index) ..  " " .. a.nvim_buf_get_name(b) .. "  "
            table.insert(lines, line)
            if string.len(line) > m.width then
                m.width = string.len(line)
            end
        end
        add_hl = function ()
            for i = 2, #lines do
                a.nvim_buf_add_highlight(m.buf, m.__props.ext_mark_ns, "BffmgrKey", i-1, 2, 3 + math.floor(i/10))
                a.nvim_buf_add_highlight(m.buf, m.__props.ext_mark_ns, "BffmgrBufname", i-1, 4 + math.floor(i/10), string.len(lines[i]))
            end
        end
    end
    table.insert(lines, "")
    m.height = #lines
    a.nvim_buf_set_option(m.buf, 'modifiable', true)
    a.nvim_buf_set_lines(m.buf, 0, #lines, false, lines)
    add_hl()
    a.nvim_buf_set_option(m.buf, 'modifiable', false)
end

local function set_keymap()
    local function close_win()
        a.nvim_win_close(a.nvim_get_current_win(), true)
        a.nvim_buf_delete(m.buf, {unload=false, force=true})
    end

    local buf_cnt = #m.buffers
    -- traverse from last to first elem, because AutoCmds just append
    for i = buf_cnt-1,1,-1 do
        local b = m.buffers[i]
        local entry_index = buf_cnt - i
        vim.keymap.set("n", m.__props.keys.sub(m.__props.keys, entry_index, entry_index), function ()
            a.nvim_win_set_buf(m.last_win, b)
            close_win()
        end, {buffer = m.buf, nowait=true})
    end

    vim.keymap.set("n", "q", function ()
        close_win()
    end, {buffer = m.buf})
end

local function get_left_offset()
    local ret = math.ceil((vim.o.columns - m.width)/2)
    return ret
end

local function get_top_offset()
    local ret = math.ceil((vim.o.lines - m.height)/2)
    return ret
end

local function find_item(table, item)
    for index, val in ipairs(table) do
        if val == item then return index end
    end
    return nil
end

-- used for debugging
local function notify_bufs_state()
    local notif = ""
    for _, buf_nr in ipairs(m.buffers) do
        notif = notif .. ", " .. buf_nr
    end
    vim.notify({notif}, true, {})
end

-- stolen from here https://stackoverflow.com/questions/49709998
local function filter_inplace(arr, func)
    local new_index = 1
    local size_orig = #arr
    for old_index, v in ipairs(arr) do
        if func(v, old_index) then
            arr[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do arr[i] = nil end
end

-- sometimes buffers become invalid over time, so i am filtering the invalid ones out
local function filter_invalid()
    filter_inplace(m.buffers, function (val, _)
        return a.nvim_buf_is_valid(val)
    end)
end

local function set_up_autocmds()
    m.__props.augroup = a.nvim_create_augroup("BuffrMgrGroup", {clear=true})
    a.nvim_create_autocmd("BufAdd", {
        callback = function ()
            filter_invalid()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            if a.nvim_buf_get_option(abuf, 'buflisted') --[[ and a.nvim_buf_is_valid(abuf) ]] then
                -- if max number of bufs reached: save least recent changed (index 1)
                -- and delete buffer, or just drop if invalid
                if #m.buffers >= m.__props.max_bufs then
                    if a.nvim_buf_is_valid(m.buffers[1]) then
                        -- write changes if the buffer has been edited before
                        if vim.fn.getbufinfo(m.buffers[1])[1].changed == 1 then
                            a.nvim_buf_call(m.buffers[1], function()
                                vim.cmd("silent! write")
                            end)
                        end
                        a.nvim_buf_delete(m.buffers[1], {unload=false, force=true})
                    end
                    -- move up
                    for i = 2, #m.buffers do
                        m.buffers[i-1]=m.buffers[i]
                    end
                    m.buffers[#m.buffers] = abuf
                else
                    m.buffers[#m.buffers+1] = abuf
                end
            end
        end,
        group = m.__props.augroup
    })
    -- put recently used buffer in front
    a.nvim_create_autocmd("BufEnter", {
        callback = function ()
            local buf = a.nvim_get_current_buf()
            local pos = find_item(m.buffers, buf)
            if pos then
                for i = pos, #m.buffers-1 do
                    m.buffers[i] = m.buffers[i+1]
                end
                m.buffers[#m.buffers] = buf
            end
        end
    })
    a.nvim_create_autocmd("BufDelete", {
        callback = function ()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            filter_inplace(m.buffers, function (val, _)
                return val ~= abuf
            end)
        end
    })
    -- Session Loading creates invalid buffers
    a.nvim_create_autocmd("SessionLoadPost", {
        callback = function ()
            filter_invalid()
        end
    })
end

m.setup = function (opts)
    m.__props.opts = opts
    m.__props.max_bufs = opts.max_bufs or 7
    m.__props.keys = opts.keys or "asdfghjkl"
    m.__props.ext_mark_ns = a.nvim_create_namespace("bffmgr.highlights")
    set_up_autocmds()
end

local function open_filled_buf()
    m.last_win = a.nvim_get_current_win()
    m.buf_win = a.nvim_open_win(m.buf, true, {
        relative = "editor",
        row = get_top_offset(),
        col = get_left_offset(),
        width = m.width,
        height = m.height,
        style = "minimal"
    })
    set_keymap()
end

m.open = function ()
    create_buf()
    -- sometimes an invalid buffer still sneaks into the list
    -- thats why i check for errors first and then try to run
    -- open again
    local success = pcall(fill_buf)
    if not success then
        filter_invalid()
        m.open()
    else
        open_filled_buf()
    end
end

return m
