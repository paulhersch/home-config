--[[
bffrmgr plugin. Basically like gleipnirs flybuf.nvim but simplified UI
and also limits amount of open buffers (autocloses)

Do not distribute this file, the code in it is horrible
--]]

local a = vim.api
local tbl_extra = require("lib.table")

local M = {}
local P = {
    props = {},
    buffers = {},
    buf_width = {},
    buf_height = {}
}


P.get_left_offset = function()
    local ret = math.ceil((vim.o.columns - P.buf_width)/2)
    return ret
end

P.get_top_offset = function()
    local ret = math.ceil((vim.o.lines - P.buf_height)/2)
    return ret
end

P.create_buf = function()
    P.buf = a.nvim_create_buf(false, true)
    a.nvim_buf_set_option(P.buf, 'filetype', 'bffrmgr')
end

P.buf_add_hl = function (content)
    for i = 2, #content do
        a.nvim_buf_add_highlight(P.buf, P.props.ext_mark_ns, "BffmgrKey", i-1, 2, 3 + math.floor(i/10))
        a.nvim_buf_add_highlight(P.buf, P.props.ext_mark_ns, "BffmgrBufname", i-1, 4 + math.floor(i/10), string.len(content[i]))
    end

end

P.fill_buf = function()
    local lines = {}
    P.buf_width = 80

    table.insert(lines, "")

    if #P.buffers < 2 then
        table.insert(lines, "  Setup not run, or no/too little textbuffers opened  ")
    else
        local buf_cnt = #P.buffers
        for i=buf_cnt-1,1,-1 do
            local b = P.buffers[i]
            local entry_index = buf_cnt - i
            local line = "  " .. P.props.keys.sub(P.props.keys, entry_index, entry_index) ..  " " .. a.nvim_buf_get_name(b) .. "  "
            table.insert(lines, line)
            if string.len(line) > P.buf_width then
                P.buf_width = string.len(line)
            end
        end
    end

    table.insert(lines, "")
    P.buf_height = #lines

    a.nvim_buf_set_lines(P.buf, 0, #lines, false, lines)
    if #P.buffers > 1 then
        P.buf_add_hl(lines)
    end
end

P.set_keymap = function()
    local function close_win()
        a.nvim_win_close(a.nvim_get_current_win(), true)
        a.nvim_buf_delete(P.buf, {unload=false, force=true})
    end

    local buf_cnt = #P.buffers
    -- traverse from last to first elem, because AutoCmds just append
    for i = buf_cnt-1,1,-1 do
        local b = P.buffers[i]
        local entry_index = buf_cnt - i
        vim.keymap.set("n", P.props.keys.sub(P.props.keys, entry_index, entry_index), function ()
            a.nvim_win_set_buf(M.last_win, b)
            close_win()
        end, {buffer = P.buf, nowait=true})
    end

    vim.keymap.set("n", "q", function ()
        close_win()
    end, {buffer = P.buf})
end

-- used for debugging
P.notify_bufs_state = function()
    local notif = ""
    for _, buf_nr in ipairs(P.buffers) do
        notif = notif .. ", " .. buf_nr
    end
    vim.notify({notif}, true, {})
end


-- sometimes buffers become invalid over time, so i am filtering the invalid ones out
P.filter_invalid = function()
    tbl_extra.filter_inplace(P.buffers, function (val, _)
        return a.nvim_buf_is_valid(val)
    end)
end

P.set_up_autocmds = function()
    P.props.augroup = a.nvim_create_augroup("BuffrMgrGroup", {clear=true})
    a.nvim_create_autocmd("BufAdd", {
        callback = function ()
            P.filter_invalid()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            if a.nvim_buf_get_option(abuf, 'buflisted') --[[ and a.nvim_buf_is_valid(abuf) ]] then
                -- if max number of bufs reached: save least recent changed (index 1)
                -- and delete buffer, or just drop if invalid
                if #P.buffers >= P.props.max_bufs then
                    if a.nvim_buf_is_valid(P.buffers[1]) then
                        -- write changes if the buffer has been edited before
                        if vim.fn.getbufinfo(P.buffers[1])[1].changed == 1 then
                            a.nvim_buf_call(P.buffers[1], function()
                                vim.cmd("silent! write")
                            end)
                        end
                        a.nvim_buf_delete(P.buffers[1], {unload=false, force=true})
                    end
                    -- move up
                    for i = 2, #P.buffers do
                        P.buffers[i-1]=P.buffers[i]
                    end
                    P.buffers[#P.buffers] = abuf
                else
                    P.buffers[#P.buffers+1] = abuf
                end
            end
        end,
        group = P.props.augroup
    })
    -- put recently used buffer in front
    a.nvim_create_autocmd("BufEnter", {
        callback = function ()
            local buf = a.nvim_get_current_buf()
            local pos = tbl_extra.find_item(P.buffers, buf)
            if pos then
                for i = pos, #P.buffers-1 do
                    P.buffers[i] = P.buffers[i+1]
                end
                P.buffers[#P.buffers] = buf
            end
        end
    })
    a.nvim_create_autocmd("BufDelete", {
        callback = function ()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            tbl_extra.filter_inplace(P.buffers, function (val, _)
                return val ~= abuf
            end)
        end
    })
    -- Session Loading creates invalid buffers
    a.nvim_create_autocmd("SessionLoadPost", {
        callback = function ()
            P.filter_invalid()
        end
    })
end

M.setup = function (opts)
    P.props.opts = opts
    P.props.max_bufs = opts.max_bufs or 7
    P.props.keys = opts.keys or "asdfghjkl"
    P.props.ext_mark_ns = a.nvim_create_namespace("bffmgr.highlights")
    P.set_up_autocmds()
end

local function open_filled_buf()
    M.last_win = a.nvim_get_current_win()
    P.buf_win = a.nvim_open_win(P.buf, true, {
        relative = "editor",
        row = P.get_top_offset(),
        col = P.get_left_offset(),
        width = P.buf_width,
        height = P.buf_height,
        style = "minimal"
    })
    P.set_keymap()
    vim.bo[P.buf]['modifiable'] = false
end

M.open = function ()
    P.create_buf()
    -- sometimes an invalid buffer still sneaks into the list
    -- thats why i check for errors first and then try to run
    -- open again
    local success = pcall(P.fill_buf)
    if not success then
        P.filter_invalid()
        M.open()
    else
        open_filled_buf()
    end
end

return M
