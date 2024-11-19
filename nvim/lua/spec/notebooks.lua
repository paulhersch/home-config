local a = vim.api

return {
    {
        "Vigemus/iron.nvim",
        dependencies = {
            "jmbuhr/otter.nvim" -- using some internal fuckery to determine ft on injections
        },
        event = "VeryLazy",
        config = function()
            local iron = require "iron.core"
            iron.setup {
                config = {
                    scratch_repl = true,
                    repl_definition = {
                        python = {
                            command = { "python" },
                            format = require("iron.fts.common").bracketed_paste_python
                        }
                    },
                    repl_open_cmd = require('iron.view').split.vertical.botright(0.4)
                },
            }


            -- https://github.com/neovim/neovim/pull/13896#issuecomment-1621702052
            local function region_to_text(region)
                local text = {}
                local maxcol = vim.v.maxcol
                for line, cols in vim.spairs(region) do
                    local endcol = cols[2] == maxcol and -1 or cols[2]
                    local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
                    text[#text + 1] = chunk
                end
                return text
            end

            local keeper = require "otter.keeper"
            a.nvim_set_keymap("v", "<C-x><C-e>", "", {
                desc =
                "Send to Iron REPL and respect ft of injections at the cursor pos at time of eval (too lazy to check properly)",
                callback = function()
                    -- force exit to normal so marks are properly set (WHY IS NEOVIM LIKE THIS FUCK)
                    vim.cmd([[execute "normal! \<ESC>"]])

                    local lang = keeper.get_current_language_context()

                    iron.send(
                        lang,
                        region_to_text(
                            vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
                        )
                    )
                end
            })
        end
    },
    {
        "jmbuhr/otter.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "neovim/nvim-lspconfig",
        },
        event = "VeryLazy",
        config = function()
            local otter = require "otter"
            otter.setup {}

            vim.api.nvim_create_user_command("OtterActivate", function()
                otter.activate()
            end, { desc = "Activate Otter for this buffer" })
        end
    },
    {
        'GCBallesteros/jupytext.nvim',
        event = "VeryLazy",
        opts = {
            style = "markdown",
            output_extension = "md",
            force_ft = "markdown",
            -- custom_language_formatting = {
            --     python = {
            --         extension = "md",
            --         style = "markdown",
            --         force_ft = "markdown", -- you can set whatever filetype you want here
            --     },
            -- }
        }
    },
    {
        "3rd/image.nvim",
        dependencies = {
            "vhyrro/luarocks"
        },
        opts = {
            backend = "ueberzug" -- as long as i dont have kitty setup, also sixel support soon?
        }
    },
    {
        "quarto-dev/quarto-nvim",
        dependencies = {
            "jmbuhr/otter.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        ft = { "quarto", "markdown" },
        opts = {
            codeRunner = {
                enabled = true,
                default_method = "molten"
            }
        }
    },
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        version = "^1.0.0",
        init = function()
            vim.g.molten_output_win_max_height = 12
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_auto_open_output = false
        end
    }
}
