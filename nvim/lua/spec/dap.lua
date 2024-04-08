local fn = vim.fn

return {
    {
        'theHamsta/nvim-dap-virtual-text',
        lazy = true,
        config = function()
            require("nvim-dap-virtual-text").setup {
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = true,
                show_stop_reason = true,
                commented = false,
                only_first_definition = true,
                all_references = false,

                --- A callback that determines how a variable is displayed or whether it should be omitted
                --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
                --- @param buf number
                --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
                --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
                --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
                display_callback = function(variable, buf, stackframe, node)
                    return variable.name .. ' = ' .. variable.value
                end,

                -- experimental features:
                virt_text_pos = 'eol',
                all_frames = false,
                virt_lines = false,
            }

        end
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'theHamsta/nvim-dap-virtual-text',
            --'rcarriga/nvim-dap-ui'
        },
        lazy = true,
        keys = {
            { "<leader>b", "<cmd> lua require('dap').toggle_breakpoint()<cr>" }
        },
        config = function ()
            vim.fn.sign_define("DapBreakpoint", { text = '●', texthl='DapBreakpointSymbol'})

            local dap = require("dap")

            dap.adapters = {
                gdb = {
                    type = "executable",
                    command = "gdb",
                    args = { "-i", "dap" }
                }
            }

            local defaults = {{
                cwd = "${workspaceFolder}",
                program = function()
                    return coroutine.create(function(coro)
                        local opts = {}
                        require("telescope.pickers")
                            .new(opts, {
                                prompt_title = "Path to executable",
                                finder = require("telescope.finders")
                                    .new_oneshot_job({ "fd", "--hidden", "--no-ignore", "--type", "x" }, {}),
                                sorter = require("telescope.config").values.generic_sorter(opts),
                                attach_mappings = function(buffer_number)
                                    require("telescope.actions")
                                        .select_default
                                        :replace(function()
                                            require("telescope.actions")
                                            .close(buffer_number)
                                            coroutine.resume(coro, require("telescope.actions.state").get_selected_entry()[1])
                                        end)
                                    return true
                                end,
                            })
                            :find()
                    end)
                end,
            }}

            local configs = {
                c = {
                    {
                        type = "gdb",
                        name = "Launch",
                        request = "launch",
                    }
                }
            }
            for lang, conf in pairs(configs) do
                dap.configurations[lang] = fn.extend(defaults, conf, "force")
            end
        end
    }
}
