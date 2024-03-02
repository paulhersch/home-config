---
-- "With other editors you edit the state of the editor,
-- with Emacs you edit the state of the art"
--                      - Programmers are also Human
--
-- This is trying to allow you to edit the state of the art
---
local v = vim
local a = v.api
local unpack = unpack or table.unpack
local concat = table.concat

local M = {}

-- private data with default arguments
local P = {
    ---@class EvaluatorArgs
    args = {
        --- keybind to trigger the eval function
        --- used for all modes
        evalkey = "<C-x><C-e>",
        --- which modes the keybind should be available
        --- for.
        --- "v": visual, eval visual block
        --- "n": normal, eval current buffer
        -- TODO: add more
        modes = {"v", "n"}
    }
}

---evaluate the string as lua code, notify via vim.notify if there have been errors
---@param code string
---@return function?
P.compile_with_errors = function (code)
    local func, err = load(code, "t")
    if err then
        vim.notify("Error reading code\n" .. err, vim.log.levels.ERROR, {})
        return nil
    end
    return func
end

---wrap function in pcall proxy
---@param func function
P.wrap_func = function (func)
    return function (...)
        local ok, ret = pcall(func, ...)
        if ok then
            return ret
        else
            -- "throw" error aka notify user
            vim.notify("Error running code\n" .. ret, vim.log.levels.ERROR, {})
        end
    end
end

---evaluate code string via load, wrap it in proxy and execute it
---the code itself can't take arguments or rely on local vars
---@param code string
M.eval_and_exec = function (code)
    local f = P.compile_with_errors(code)
    if f then
        return P.wrap_func(f)()
    end
end

-- as per
-- https://github.com/neovim/neovim/pull/21115#issuecomment-1320900205
---@return table
P.get_visual = function()
    local _, ls, cs = unpack(vim.fn.getpos('v'))
    local _, le, ce = unpack(vim.fn.getpos('.'))
    return a.nvim_buf_get_text(0, ls-1, cs-1, le-1, ce, {})
end

M.eval_visual_block = function ()
    M.eval_and_exec(
        concat(P.get_visual(), "\n")
    )
end

M.eval_current_buf = function ()
    M.eval_and_exec(
        concat(
            a.nvim_buf_get_lines(
                a.nvim_win_get_buf(0),
                0,
                -1,
                false
            )
        )
    )
end

---@param args EvaluatorArgs
---set up keybinds for eval inside nvim lua runtime
---defaults:
---{
---  evalkey = "<C-x><C-e>"
---}
M.setup = function(args)
    P.args = v.tbl_extend("force", P.args, args)

    for _, mode in pairs(P.args.modes) do
        if mode == "n" then
            -- eval buffer
            vim.keymap.set (
                "n",
                P.args.evalkey,
                M.eval_current_buf,
                {
                    noremap = true,
                    desc = "evaluate lua code in current buffer"
                }
            )
        elseif mode == "v" then
            -- eval of visual block
            vim.keymap.set (
                "v",
                P.args.evalkey,
                M.eval_visual_block,
                {
                    noremap = true,
                    desc = "evaluate lua code in visual block"
                }
            )
        end
    end
end

return M
