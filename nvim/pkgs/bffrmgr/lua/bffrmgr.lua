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
    buf_width = 0,
    buf_height = 0
}


P.get_left_offset = function()
    local ret = math.ceil((vim.o.columns - P.buf_width) / 2)
    return ret
end

P.get_top_offset = function()
    local ret = math.ceil((vim.o.lines - P.buf_height) / 2)
    return ret
end

P.create_buf = function()
    P.buf = a.nvim_create_buf(false, true)
    a.nvim_set_option_value('filetype', 'bffrmgr', { buf = P.buf })
    a.nvim_buf_set_name(P.buf, 'buffers')
end

P.fill_buf = function()
    a.nvim_buf_clear_namespace(P.buf, P.props.ext_mark_ns, 0, -1)
    local lines = {}
    local current_cwd = vim.fn.getcwd() .. "/"
    P.buf_width = 80 -- default width

    if #P.buffers < 2 then
        local text = "Setup not run, or no/too little textbuffers opened"
        table.insert(
            lines,
            string.rep(" ", math.floor((P.buf_width - string.len(text)) / 2)) ..
            text .. string.rep(" ", math.ceil((P.buf_width - string.len(text)) / 2))
        )
        a.nvim_buf_set_lines(P.buf, 0, #lines - 1, false, lines)
        a.nvim_buf_add_highlight(P.buf, P.props.ext_mark_ns, "BffrmgrBufname", 0, 0, -1)
    else
        local buf_cnt = #P.buffers

        lines = {}
        for i = 2, buf_cnt do
            local b = P.buffers[i]
            local relative_name = string.gsub(a.nvim_buf_get_name(b), current_cwd, "")
            if string.len(relative_name) + 2 > P.buf_width then
                P.buf_width = string.len(relative_name) + 2 -- spacing for key
            end
            table.insert(lines, relative_name)
        end

        -- pad all lines because vim highlighting wont do this shit otherwise
        -- string.format fails for format strings with a width > 99 characters (WTF)
        for i, line in pairs(lines) do
            lines[i] = line .. string.rep(" ", P.buf_width - #line - 2)
        end

        a.nvim_buf_set_lines(P.buf, 0, #lines - 1, false, lines)

        -- highlight and key as virtual text
        for i = 1, #lines do
            local key = P.props.keys.sub(P.props.keys, i, i)
            a.nvim_buf_add_highlight(P.buf, P.props.ext_mark_ns, "BffrmgrBufname", i - 1, 0, -1)
            a.nvim_buf_set_extmark(P.buf, P.props.ext_mark_ns, i - 1, 0, {
                end_col = 2,
                virt_text = { { key .. " ", "BffrmgrKey" } },
                virt_text_pos = "inline"
            })
        end
    end

    P.buf_height = #lines

    -- a.nvim_buf_set_lines(P.buf, 0, #lines, false, lines)
    -- if #P.buffers > 1 then
    --     P.buf_add_hl(lines)
    -- end
end

P.set_keymap = function()
    local function close_win()
        a.nvim_win_close(P.buf_win, true)
        a.nvim_buf_delete(P.buf, { force = true })
    end

    local buf_cnt = #P.buffers
    -- traverse from last to first elem, because AutoCmds just append
    for i = 2, buf_cnt do
        local b = P.buffers[i]
        vim.keymap.set("n", P.props.keys.sub(P.props.keys, i - 1, i - 1), function()
            a.nvim_win_set_buf(M.last_win, b)
            close_win()
        end, { buffer = P.buf, nowait = true })
    end

    vim.keymap.set("n", "<Enter>", function()
        -- cant switch if <= 1 bufs open
        if #P.buffers <= 1 then
            return
        end
        local pos = a.nvim_win_get_cursor(P.buf_win)
        a.nvim_win_set_buf(M.last_win, P.buffers[pos[1] + 1])
        close_win()
    end, { buffer = P.buf })
    vim.keymap.set("n", "q", function()
        close_win()
    end, { buffer = P.buf })
    vim.keymap.set("n", "<esc>", function()
        close_win()
    end, { buffer = P.buf })
end

-- used for debugging
P.notify_bufs_state = function()
    local notif = ""
    for _, buf_nr in ipairs(P.buffers) do
        notif = notif .. ", " .. buf_nr
    end
    vim.notify({ notif }, true, {})
end

P.filter_invalid = function()
    tbl_extra.filter_inplace(P.buffers, function(val, _)
        return a.nvim_buf_is_valid(val)
    end)
end

P.set_up_autocmds = function()
    P.props.augroup = a.nvim_create_augroup("BuffrMgrGroup", { clear = true })
    a.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
        callback = function()
            -- filter out buffers that might have become invalid
            P.filter_invalid()
            local added_buf = tonumber(vim.fn.expand('<abuf>'))
            if a.nvim_get_option_value('buflisted', { buf = added_buf }) then
                tbl_extra.push_or_move_up(P.buffers, added_buf, P.props.max_bufs, function(buf)
                    if a.nvim_buf_is_valid(buf) then
                        if vim.fn.getbufinfo(buf)[1].changed == 1 then
                            a.nvim_buf_call(buf, function()
                                vim.cmd "silent! write"
                            end)
                        end
                        a.nvim_buf_delete(buf, {
                            unload = false,
                            force = true
                        })
                    end
                end)
            end
        end,
        group = P.props.augroup
    })
    a.nvim_create_autocmd("BufDelete", {
        callback = function()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            local index = tbl_extra.find_item(P.buffers, abuf)
            if index then
                table.remove(P.buffers, index)
            end
        end
    })
    -- Session Loading sometimes creates invalid buffers, filter
    -- immediately in case this happens
    a.nvim_create_autocmd("SessionLoadPost", {
        callback = function()
            P.filter_invalid()
        end
    })
end

M.setup = function(opts)
    P.props.opts = opts
    P.props.max_bufs = opts.max_bufs or 7
    P.props.keys = opts.keys or "asdfghjkl"
    P.props.ext_mark_ns = a.nvim_create_namespace("bffrmgr.highlights")
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
        style = "minimal",
        border = "single"
    })
    P.set_keymap()
    vim.bo[P.buf]['modifiable'] = false
end

M.open = function()
    if not P.buf or not a.nvim_buf_is_valid(P.buf) then
        P.create_buf()
    end
    -- sometimes an invalid buffer still sneaks into the list
    P.filter_invalid()
    P.fill_buf()
    open_filled_buf()
end

return M
