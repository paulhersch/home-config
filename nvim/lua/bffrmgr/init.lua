local a = vim.api

local m = {}
m.__props = {}
m.__props.keys = "asdfghjkl"
m.buffers = {}

local function create_buf()
    m.buf = a.nvim_create_buf(false, false)
    a.nvim_buf_set_option(m.buf, 'filetype', 'bffrmgr')
end

local function fill_buf()
    local lines = {}
    m.width = 80
    for i, b in ipairs(m.buffers) do
        local bname = a.nvim_buf_get_name(b)
        table.insert(lines, "[" .. m.__props.keys.sub(m.__props.keys, i, i) ..  "] " .. bname)
        if string.len(bname) > m.width then
            m.width = string.len(bname)
        end
    end
    m.height = #lines
    a.nvim_buf_set_option(m.buf, 'modifiable', true)
    a.nvim_buf_set_lines(m.buf, 0, #lines, false, lines)
    a.nvim_buf_set_option(m.buf, 'modifiable', false)
end

local function get_left_offset()
    local ret = math.ceil((vim.o.columns - m.width)/2)
    return ret
end

local function get_top_offset()
    local ret = math.ceil((vim.o.lines - m.height)/2)
    return ret
end

local function set_keymap()
    local function close_win()
        a.nvim_win_close(a.nvim_get_current_win(), true)
        a.nvim_buf_delete(m.buf, {unload=false, force=true})
    end

    local i = 0
    for _, b in ipairs(m.buffers) do
        i = i + 1
        vim.keymap.set("n", m.__props.keys.sub(m.__props.keys, i, i), function ()
            a.nvim_win_set_buf(m.last_win, b)
            close_win()
        end, {buffer = m.buf, nowait=true})
    end

    vim.keymap.set("n", "q", function ()
        close_win()
    end, {buffer = m.buf})
end

m.open = function ()
    create_buf()
    fill_buf()
    m.last_win = a.nvim_get_current_win()
    m.buf_win = a.nvim_open_win(m.buf, true, {
        relative = "editor",
        row = get_top_offset(),
        col = get_left_offset(),
        width = m.width,
        height = m.height
    })
    a.nvim_win_set_option(m.buf_win, 'number', false)
    set_keymap()
end

local function set_up_autocmds()
    m.__props.augroup = a.nvim_create_augroup("BuffrMgrGroup", {clear=true})
    a.nvim_create_autocmd("BufAdd", {
        callback = function ()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            -- vim.notify({"" .. abuf}, true, {})
            if a.nvim_buf_get_option(abuf, 'buflisted') then
                -- if max number of bufs reached: save least recent changed (index 1)
                -- and delete buffer
                if #m.buffers >= m.__props.max_bufs then
                    a.nvim_buf_call(m.buffers[1], function()
                        vim.cmd("silent! write")
                    end)
                    a.nvim_buf_delete(m.buffers[1], {unload=false, force=true})
                    -- move up
                    for i = 2, #m.buffers do
                        m.buffers[i-1]=m.buffers[i]
                    end
                    m.buffers[#m.buffers] = abuf
                else
                    m.buffers[#m.buffers+1] = abuf
                end
                local notif = ""
                for _, buf_nr in ipairs(m.buffers) do
                    notif = notif .. ", " .. buf_nr
                end
                vim.notify({notif}, true, {})
            end
        end,
        group = m.__props.augroup
    })
end

m.setup = function (opts)
    m.__props.max_bufs = opts.max_bufs
    set_up_autocmds()
end

return m
