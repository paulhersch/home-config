--
-- set up alpha after essential stuff loaded
--
-- in after, because needs to be loaded before UI Enter but i also
-- want lazy startup stats, so a redraw has to happend after UI Enter
--

local a = vim.api
local stats = require("lazy").stats
local utils = require("session_manager.utils")
local session_manager = require("session_manager")
local alpha = require("alpha")
local this_ascii = require("asciis").choose_random()

local max_sessions = 4
local session_shortcuts = "asdfghjkl"
-- to replace /home/user with ~
local home_dir = os.getenv("HOME")

local function last_sessions()
    local sessions = utils.get_sessions()
    local temp_max_sessions = #sessions <= max_sessions and #sessions or max_sessions

    local max_line_len = 0

    for i = 1, temp_max_sessions do
        local len = string.len(sessions[i].dir:__tostring())
        if len > max_line_len then
            max_line_len = len
        end
    end

    local lines_specs = {}
    for i = 1, temp_max_sessions do
        local session = sessions[i]
        -- text associated with the session
        local session_strrep = session.dir:__tostring():gsub(home_dir, "~")
        local dirname_start, dirname_end = string.find(session_strrep, "[^/]+$")

        local start_this_session = function()
            utils.load_session(session.filename, false)
        end

        table.insert(lines_specs, {
            type = "button",
            -- replace home folder name with ~
            val = session_strrep,
            on_press = start_this_session,
            opts = {
                keymap = {
                    "n",
                    session_shortcuts:sub(i, i),
                    start_this_session,
                    { nowait = true, silent = true }
                },
                shortcut = string.format("[%s]  ", session_shortcuts:sub(i, i)),
                align_shortcut = "left",
                position = "center",
                hl = {
                    { "DashboardFooter", 0,                 dirname_start - 1 },
                    { "DashboardCenter", dirname_start - 1, dirname_end }
                },
                hl_shortcut = "DashboardKey",
                cursor = 1,
                width = max_line_len + 5,
                shrink_margin = true
            }
        })
    end
    table.insert(lines_specs, {
        type = "button",
        val = " ",
        on_press = session_manager.load_session,
        opts = {
            keymap = {
                "n",
                session_shortcuts:sub(max_sessions + 1, max_sessions + 1),
                session_manager.load_session,
                { nowait = true, silent = true }
            },
            shortcut = string.format("[%s]  ", session_shortcuts:sub(max_sessions + 1, max_sessions + 1)),
            align_shortcut = "left",
            position = "center",
            hl = "DashboardShortCut",
            hl_shortcut = "DashboardKey",
            cursor = 1,
            width = max_line_len + 5,
            shrink_margin = true
        }
    })
    table.insert(lines_specs, 1, {
        type = "text",
        -- +4 compared to upper text for indent
        val = string.format("%-" .. (max_line_len + 6) .. "s", "  Recent Sessions"),
        opts = { hl = { { "DashboardEmphasized", 0, 20 } }, position = "center" }
    })
    return lines_specs
end

local sessions = last_sessions()

alpha.setup {
    opts = {
        noautocmd = true,
    },
    layout = {
        {
            -- Header + 12 lines is the whole width
            -- dynamic padding based on that
            type = "text",
            val = function()
                local pad = {}
                for _ = 1, ((vim.o.lines - (#this_ascii + 12)) / 2) do
                    table.insert(pad, "")
                end
                return pad
            end
        },
        {
            type = "text",
            opts = {
                position = "center",
                hl = "DashboardHeader"
            },
            -- this way the ascii can actually be switched out
            val = this_ascii
        },
        {
            type = "group",
            val = sessions,
            opts = { spacing = 1 }
        },
        {
            type = "text",
            val = function()
                local curstat = stats()
                return string.format(
                    "started up in %.2fms",
                    curstat.startuptime
                )
            end,
            opts = {
                position = "center",
                hl = "DashboardFooter"
            }
        }
    }
}

a.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    once = true,
    callback = function()
        alpha.redraw()
    end
})
