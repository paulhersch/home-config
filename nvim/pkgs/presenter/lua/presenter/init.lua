-- internal presenter module because presenting.nvim did a
-- few things too many for me
local a = vim.api
local fn = vim.fn

-- available
local M = {}

-- internal state
local P = {
    -- windows and buffers
    presbuf = nil,
    preswin = nil,
    sourcebuf = nil,
    sourcewin = nil,
    -- variables
    started = false,
    -- we will split the text inside the buffer in chunks here
    chunks = {},
    current_slide = 1,
}

P.init_for_buffer = function(sourcwin)
    P.sourcewin = sourcwin
    P.sourcebuf = a.nvim_win_get_buf(P.sourcewin)

    local ft = a.nvim_get_option_value("filetype", { buf = P.sourcebuf })
    if not ft or P.config.patterns[ft] == nil then
        error("No Pattern for current Filetype (" .. ft .. "), can't parse file")
    end
    local pat = P.config.patterns[ft]

    local lines = vim.api.nvim_buf_get_lines(P.sourcebuf, 0, -1, false)
    local current_parsed_slide = 0
    -- check if each line is a sep
    for _, line in ipairs(lines) do
        -- sep found -> new chunk
        if line:match(pat) then
            current_parsed_slide = current_parsed_slide + 1
        end
        -- if we are past slide 0, we will add the lines into our chunks
        if current_parsed_slide ~= 0 then
            -- have we started the chunk yet?
            if not P.chunks[current_parsed_slide] then
                P.chunks[current_parsed_slide] = { "" }
            end
            -- check if empty line
            table.insert(P.chunks[current_parsed_slide], line)
        end
    end

    P.presbuf = a.nvim_create_buf(false, true)
    if not P.presbuf or P.presbuf == 0 then
        error("Couldn't create buffer for the presentation")
    end
    a.nvim_set_option_value("filetype", ft, { buf = P.presbuf })

    P.preswin = a.nvim_open_win(P.presbuf, true, {
        relative = "win",
        win = P.sourcewin,
        zindex = 1,
        style = "minimal",
        row = 0,
        col = 0,
        width = fn.winwidth(P.sourcewin),
        height = fn.winheight(P.sourcewin),
        border = { " " }
    })

    -- Make Window use normal highlights
    a.nvim_set_option_value("winhl", "NormalFloat:Normal,FloatBorder:Normal,WinBar:Normal",
        { win = P.preswin })

    -- set up keybinds for buf
    for lhs, rhs in pairs(P.config.keys) do
        if type(rhs) == "string" then
            a.nvim_buf_set_keymap(P.presbuf, "n", lhs, rhs, { silent = true, noremap = true })
        elseif type(rhs) == "function" then
            a.nvim_buf_set_keymap(P.presbuf, "n", lhs, "", { silent = true, noremap = true, callback = rhs })
        end
    end

    a.nvim_create_autocmd("WinResized", {
        group = P.presenter_augroup,
        callback = function() P.resize() end,
    })
end

P.resize = function()
    -- closing causes resize event
    if not P.started then return end
    P.winheight = fn.winheight(P.sourcewin)
    P.winwidth = fn.winwidth(P.sourcewin)

    -- set window dimensions
    a.nvim_win_set_height(P.preswin, P.winheight)
    a.nvim_win_set_width(P.preswin, P.winwidth)


    -- add lines to the chunks so we can move the cursor out of the way
    local targetlinecount = P.winheight - 2
    for _, chunk in ipairs(P.chunks) do
        -- remove previous empty lines in chunks
        while #chunk > targetlinecount do
            if chunk[#chunk]:match("^%s*$") then
                table.remove(chunk, #chunk)
            else
                goto done
            end
        end
        while #chunk < targetlinecount do
            table.insert(chunk, " ")
        end
        :: done ::
    end

    P.redraw()
end

P.redraw = function()
    local chunk = P.chunks[P.current_slide]
    local slideinfo = string.format("[%i/%i]", P.current_slide, #P.chunks)

    a.nvim_set_option_value("modifiable", true, { buf = P.presbuf })
    a.nvim_set_option_value("winbar", "%=" .. slideinfo, { win = P.preswin })
    a.nvim_buf_set_lines(P.presbuf, 0, -1, false, chunk)
    -- "scroll up" and then set to the bottom
    a.nvim_win_set_cursor(P.preswin, { 1, 0 })
    a.nvim_win_set_cursor(P.preswin, { P.winheight - 3, 0 })
    a.nvim_set_option_value("modifiable", false, { buf = P.presbuf })
end

M.start = function()
    if P.started then return end

    P.init_for_buffer(a.nvim_get_current_win())
    P.started = true
    P.old_laststatus = vim.opt.laststatus
    vim.opt.laststatus = 0
    P.redraw()
end

M.stop = function()
    if not P.started then return end

    -- if user didnt close already
    if a.nvim_win_is_valid(P.preswin) then
        a.nvim_win_close(P.preswin, true)
    end
    vim.opt.laststatus = P.old_laststatus
    -- delete data
    P.chunks = {}
    P.current_slide = 1
    P.started = false
end

M.next = function()
    if not P.started then return end
    local nextnum = P.current_slide < #P.chunks and P.current_slide + 1 or #P.chunks
    if nextnum ~= P.current_slide then
        P.current_slide = nextnum
        P.redraw()
    end
end

M.prev = function()
    if not P.started then return end
    local nextnum = P.current_slide > 1 and P.current_slide - 1 or 1
    if nextnum ~= P.current_slide then
        P.current_slide = nextnum
        P.redraw()
    end
end

M.toggle = function()
    if not P.started then
        M.start()
    else
        M.stop()
    end
end

M.default_config = {
    patterns = {
        markdown = "^#+ ",
    },
    keys = {
        ["n"] = M.next,
        ["<Right>"] = M.next,
        ["<Space>"] = M.next,
        ["<CR>"] = M.next,
        ["<BS>"] = M.prev,
        ["<Left>"] = M.prev,
        ["q"] = M.stop
    }
}

M.setup = function(opts)
    -- check if opts is a table and tbl_extend to loaded config
    vim.validate({ opts = { opts, "table", true } })
    P.config = vim.tbl_deep_extend("force", vim.deepcopy(M.default_config), opts or {})

    -- setup cmd and Autogroup
    a.nvim_create_user_command("PresentMD", M.toggle, {})

    -- create funny Cursor HL group to hide the cursor
    a.nvim_set_hl(0, "HiddenCursor", { blend = 100, link = "Normal" })

    P.presenter_augroup = vim.api.nvim_create_augroup("Presenter", {})
end

return M
