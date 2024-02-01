return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'theHamsta/nvim-dap-virtual-text',
        --'rcarriga/nvim-dap-ui'
    },
    keys = {
        { "<leader>b", "<cmd> lua require('dap').toggle_breakpoint()<cr>" }
    },
    config = function ()
        local dap = require("dap")

        dap.adapters = {
            -- dotnet = {
            --     type = 'executable',
            --     command = 'netcoredbg',
            --     args = {'--interpreter=vscode'}
            -- },
            -- needs gdb >=14
            gdb = {
                type = "executable",
                command = "gdb",
                args = { "-i", "dap" }
            }
        }

        dap.configurations = {
            cs = {
                {
                    type = "dotnet",
                    name = "launch - netcoredbg",
                    request = "launch",
                    program = function()
                        local ret
                        vim.ui.select(vim.split(vim.fn.system("ls ".. vim.fn.getcwd() .. '/bin/Debug/net$(dotnet --version | cut -d "." -f 1,2)'), "\n"),{
                            prompt = 'Select Program to Debug',
                        }, function (path)
                                ret = path
                            end)
                        return ret
                    end,
                },
            },
            c = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = "${workspaceFolder}",
                },
            }
        }

        vim.fn.sign_define("DapBreakpoint", { text = '●', texthl='DapBreakpointSymbol'})


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
}
