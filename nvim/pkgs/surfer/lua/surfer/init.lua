local ts = vim.treesitter
local a = vim.api

local M = {}
local P = {}

P.default_opts = {
    modestring = "v"
}

P.visual_range = function(node, opts)
    if not node then
        return
    end
    opts = vim.tbl_extend("force", opts or {}, P.default_opts)

    local start_row, start_col, end_row, end_col = node:range()
    vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    vim.cmd("normal! " .. vim.api.nvim_replace_termcodes(opts.modestring, true, false, true))
    -- some parsers weirdly set range of one row too large with column 0
    -- so that case is handled here
    if end_col == 0 then
        end_row = math.max(0, end_row - 1)
        end_col = #(vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false))[1]
    end

    vim.notify(string.format("[%i, %i] - [%i, %i]", start_row, start_col, end_row, end_col))
    vim.api.nvim_win_set_cursor(0, { end_row + 1, math.max(0, end_col - 1) })
end

P.get_outermost = function()
    -- some selection logic is from here
    -- https://github.com/BibekBhusal0/tree-hierarchy.nvim/blob/master/lua/tree-hierarchy/init.lua
    local sr, sc, er, ec = nil, nil, nil, nil
    -- check if in visual mode
    if vim.fn.mode():match("[vV\22]") then
        local posv, posdot
        posv = vim.fn.getpos("v")
        posdot = vim.fn.getpos(".")

        sr = posv[2] - 1
        sc = posv[3] - 1
        er = posdot[2] - 1
        ec = posdot[3]

        if sr > er or (sr == er and sc > ec) then
            local ert, ect = er, ec
            er = sr
            sr = ert
            ec = sc
            sc = ect
        end
    end

    local node = ts.get_node()
    if not node then return end

    local parent = node:parent()
    if not parent then return node, node end

    -- if we are in visual mode, and node range is smaller than
    -- current selection, we go up until maximum selected node is hit
    -- before selection for outermost child node
    -- this helps in cases, where one node has three children with same
    -- range (strings)
    while sr ~= nil and parent ~= nil do
        local psr, psc, per, pec = parent:range()

        if per == 0 then
            per = math.max(0, per - 1)
            pec = #(vim.api.nvim_buf_get_lines(0, per, per + 1, false))[1]
        end
        if psr < sr or psc < sc or per > er or pec > ec then
            -- parent larger than selection, stop search
            break
        end
        node = parent
        parent = node:parent()
    end
    -- analogous, but doesn't care about visual selection
    while parent ~= nil and parent:child_count() == 1 do
        node = parent
        parent = node:parent()
    end

    return node, parent
end

M.select_current = function(opts)
    local node, _ = P.get_outermost()
    P.visual_range(node, opts)
end

M.select_parent = function(opts)
    local _, parent = P.get_outermost()
    P.visual_range(parent, opts)
end

M.select_child = function(opts)
    local node = ts.get_node()
    if not node then return end

    local child = node:child(0)
    while child and child:child_count() == 1 do
        node = child
        child = node:child(0)
    end

    P.visual_range(child or node, opts)
end

M.select_prev_sib = function(opts)
    local node, _ = P.get_outermost()
    -- local node = ts.get_node()
    if not node then return end

    local sib = node:prev_sibling()
    while sib and sib:extra() do
        node = sib
        sib = node:prev_sibling()
    end

    P.visual_range(sib or node, opts)
end

M.select_next_sib = function(opts)
    local node, _ = P.get_outermost()
    -- local node = ts.get_node()
    if not node then return end

    local sib = node:next_sibling()
    while sib and sib:extra() do
        node = sib
        sib = node:next_sibling()
    end

    P.visual_range(sib or node, opts)
end

return M
