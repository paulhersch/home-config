---
-- Codegolfing primes 99 plugin using ollama, but i had 5h of sleep and listened to breakcore on full volume
---

require("clanker.types")
local prompts = require("clanker.prompt")
local ollama_api = require("clanker.ollama")

local a = vim.api
local uv = vim.uv

local P = {
    ---@type OllamaOpts
    ollama = {
        model = "qwen3:8b",
        host = "localhost",
        port = "11434"
    },
    spinner_chars = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
}

local M = {}

P.handle_job_stdout = function(buf, range_start, range_end, extmark_id)
    -- we should get the response at some time, when we receive it input in file
    return function(_, data, _)
        vim.schedule(function()
            local response = ollama_api.parse_return_body(data)
            local lines = vim.fn.split(response, "\n", false)
            a.nvim_buf_del_extmark(buf, P._namespace, extmark_id)
            a.nvim_buf_set_lines(buf, range_start - 1, range_end, false, lines)
        end)
    end
end

--
-- use position as starting point to insert the response
-- if range_start and range_end point to the same line, we
-- simply append to this line, otherwise the selected lines
-- will be replaced by the response
--
---@param buf number buffer number
---@param range_start number starting line
---@param range_end number ending line
---@param prompt string the final prompt to the clanker
---
P.make_clanker_do = function(buf, range_start, range_end, prompt)
    -- add extmark with hint that clanker is working, and create the hook to change text after request finished
    local spinner_pos = 0
    local extmark_id = a.nvim_buf_set_extmark(buf, P._namespace, range_start - 1, 0,
        {
            virt_text = { { "clanker is working on it " .. P.spinner_chars[spinner_pos + 1], "DiagnosticVirtualTextHint" } },
            virt_text_pos = "eol"
        })
    ollama_api.generate_job(P.ollama, prompt, P.handle_job_stdout(buf, range_start, range_end, extmark_id))

    -- Add a uv timer to create funny spinner
    local timer = uv.new_timer()
    timer:start(400, 400, function()
        vim.schedule(function()
            if #a.nvim_buf_get_extmark_by_id(buf, P._namespace, extmark_id, {}) == 0 then
                timer:stop()
                timer:close()
            else
                a.nvim_buf_set_extmark(buf, P._namespace, range_start - 1, 0, {
                    id = extmark_id,
                    virt_text = { { "clanker is working on it " .. P.spinner_chars[spinner_pos + 1], "DiagnosticVirtualTextHint" } },
                    virt_text_pos = "eol"
                })
                spinner_pos = (spinner_pos + 1) % #P.spinner_chars
            end
        end)
    end)
end

--- fill function using provided prompt
--- cmd_opts are from cmdline input, opts are "true" options
M.clanker_function = function(cmd_opts)
    local buf = a.nvim_get_current_buf()
    local file = table.concat(a.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local ft = a.nvim_get_option_value("filetype", { buf = 0 })
    local ls, le = 0, 0

    vim.ui.input({ prompt = "what shall the clanker do?" }, function(extra_inst)
        if cmd_opts.range == 0 then
            -- get range from Treesitter Node under cursor if no range
            local node = vim.treesitter.get_node()
            if not node then
                vim.notify(
                    "Couldn't find Function Treesitter Node under cursor and no range supplied," ..
                    " can't ask clanker to fill a function for You", vim.log.levels.ERROR)
                return
            end
            -- check if node is a function
            local node_type = node:type()
            if node_type and string.find(node_type, "function") then
                ls, _, _ = node:start()
                ls = ls + 1
                le, _, _ = node:end_()
                le = le + 1
            end
        elseif cmd_opts.range == 2 then
            -- otherwise use the selected lines
            ls = cmd_opts.line1
            le = cmd_opts.line2
        end

        local lines = table.concat(a.nvim_buf_get_lines(0, ls - 1, le, false), "\n")

        local final_prompt = prompts.fill_func(file, lines, ft, extra_inst)
        P.make_clanker_do(buf, ls, le, final_prompt)
    end)
end

M.clanker_visual = function(cmd_opts)
    if cmd_opts.range == 0 then
        vim.notify("Visual mode range is required for clanker_visual", vim.log.levels.ERROR)
        return
    end
    local buf = a.nvim_get_current_buf()
    local file = table.concat(a.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local ls = cmd_opts.line1
    local le = cmd_opts.line2
    local lines = table.concat(a.nvim_buf_get_lines(0, ls - 1, le, false), "\n")
    vim.ui.input({ prompt = "What should the clanker do?" }, function(extra_inst)
        local final_prompt = prompts.visual(file, lines, ft, extra_inst)
        P.make_clanker_do(buf, ls, le, final_prompt)
    end)
end

-- list all subcommands for completion
local subcmds = {}
for funcname, _ in pairs(M) do
    funcname, _ = string.gsub(funcname, "clanker_", "")
    table.insert(subcmds, funcname)
end

M.setup = function(opts)
    P = vim.tbl_extend("force", P, opts)
    P._namespace = a.nvim_create_namespace("clanker_info")

    a.nvim_create_user_command("Clanker", function(params)
        local fargs = params.fargs
        if M["clanker_" .. fargs[1]] then
            M["clanker_" .. fargs[1]](params)
        else
            vim.notify("Clanker Command arguments not supported", vim.log.levels.ERROR)
        end
    end, {
        desc = "Clanker command",
        range = true,
        nargs = 1,
        complete = function(ArgLead, CmdLine, _)
            if #vim.fn.split(CmdLine) > 1 then
                return {}
            end
            local candidates = {}
            for _, cand in ipairs(subcmds) do
                if string.match(cand, ArgLead) then
                    table.insert(candidates, cand)
                end
            end
            return candidates
        end
    })
end

return M
